package com.example.gym

import android.app.job.JobInfo
import android.app.job.JobParameters
import android.app.job.JobScheduler
import android.app.job.JobService
import android.content.ComponentName
import android.content.Context
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.firestore.FirebaseFirestore

/**
 * Every ~15 minutes: catch up on anything the listener service missed (it
 * may have been killed by the OEM), then try to bring the service back.
 * Persisted across reboots, needs a network connection to run.
 */
class KeepAliveJob : JobService() {

    companion object {
        private const val JOB_ID = 7311
        private const val PERIOD_MS = 15L * 60 * 1000

        fun schedule(context: Context) {
            val scheduler =
                context.getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler
            if (scheduler.getPendingJob(JOB_ID) != null) return
            val job = JobInfo.Builder(JOB_ID, ComponentName(context, KeepAliveJob::class.java))
                .setPeriodic(PERIOD_MS)
                .setPersisted(true)
                .setRequiredNetworkType(JobInfo.NETWORK_TYPE_ANY)
                .build()
            scheduler.schedule(job)
        }

        fun cancel(context: Context) {
            val scheduler =
                context.getSystemService(Context.JOB_SCHEDULER_SERVICE) as JobScheduler
            scheduler.cancel(JOB_ID)
        }
    }

    override fun onStartJob(params: JobParameters): Boolean {
        val user = FirebaseAuth.getInstance().currentUser
        if (user == null || user.isAnonymous) return false
        val me = user.uid
        val inbox = PushInbox(this)
        val db = FirebaseFirestore.getInstance()

        var pending = 2
        fun done() {
            if (--pending == 0) {
                if (!FriendPushService.running) FriendPushService.start(this)
                jobFinished(params, false)
            }
        }

        db.collection("chats").whereArrayContains("members", me).get()
            .addOnSuccessListener { snap ->
                for (d in snap.documents) inbox.handleChat(me, d)
                done()
            }
            .addOnFailureListener { done() }

        db.collection("friendRequests")
            .whereEqualTo("to", me)
            .whereEqualTo("status", "pending")
            .get()
            .addOnSuccessListener { snap ->
                for (d in snap.documents) inbox.handleIncomingRequest(me, d)
                done()
            }
            .addOnFailureListener { done() }

        return true
    }

    override fun onStopJob(params: JobParameters): Boolean = true
}
