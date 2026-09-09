// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, ExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 80,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<MuscleGroup, String> muscleGroup =
      GeneratedColumn<String>(
        'muscle_group',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MuscleGroup>($ExercisesTable.$convertermuscleGroup);
  @override
  late final GeneratedColumnWithTypeConverter<ExerciseRole, String> role =
      GeneratedColumn<String>(
        'role',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<ExerciseRole>($ExercisesTable.$converterrole);
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repRangeMinMeta = const VerificationMeta(
    'repRangeMin',
  );
  @override
  late final GeneratedColumn<int> repRangeMin = GeneratedColumn<int>(
    'rep_range_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repRangeMaxMeta = const VerificationMeta(
    'repRangeMax',
  );
  @override
  late final GeneratedColumn<int> repRangeMax = GeneratedColumn<int>(
    'rep_range_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _incrementKgMeta = const VerificationMeta(
    'incrementKg',
  );
  @override
  late final GeneratedColumn<double> incrementKg = GeneratedColumn<double>(
    'increment_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isUnilateralMeta = const VerificationMeta(
    'isUnilateral',
  );
  @override
  late final GeneratedColumn<bool> isUnilateral = GeneratedColumn<bool>(
    'is_unilateral',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_unilateral" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isBodyweightMeta = const VerificationMeta(
    'isBodyweight',
  );
  @override
  late final GeneratedColumn<bool> isBodyweight = GeneratedColumn<bool>(
    'is_bodyweight',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_bodyweight" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isExplosiveMeta = const VerificationMeta(
    'isExplosive',
  );
  @override
  late final GeneratedColumn<bool> isExplosive = GeneratedColumn<bool>(
    'is_explosive',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_explosive" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  late final GeneratedColumnWithTypeConverter<Muscle?, String> primaryMuscle =
      GeneratedColumn<String>(
        'primary_muscle',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Muscle?>($ExercisesTable.$converterprimaryMusclen);
  @override
  late final GeneratedColumnWithTypeConverter<Muscle?, String> secondaryMuscle =
      GeneratedColumn<String>(
        'secondary_muscle',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      ).withConverter<Muscle?>($ExercisesTable.$convertersecondaryMusclen);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCustomMeta = const VerificationMeta(
    'isCustom',
  );
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
    'is_custom',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_custom" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _archivedMeta = const VerificationMeta(
    'archived',
  );
  @override
  late final GeneratedColumn<bool> archived = GeneratedColumn<bool>(
    'archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    synced,
    deleted,
    id,
    name,
    muscleGroup,
    role,
    targetSets,
    repRangeMin,
    repRangeMax,
    incrementKg,
    isUnilateral,
    isBodyweight,
    isExplosive,
    primaryMuscle,
    secondaryMuscle,
    notes,
    isCustom,
    archived,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    } else if (isInserting) {
      context.missing(_targetSetsMeta);
    }
    if (data.containsKey('rep_range_min')) {
      context.handle(
        _repRangeMinMeta,
        repRangeMin.isAcceptableOrUnknown(
          data['rep_range_min']!,
          _repRangeMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repRangeMinMeta);
    }
    if (data.containsKey('rep_range_max')) {
      context.handle(
        _repRangeMaxMeta,
        repRangeMax.isAcceptableOrUnknown(
          data['rep_range_max']!,
          _repRangeMaxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repRangeMaxMeta);
    }
    if (data.containsKey('increment_kg')) {
      context.handle(
        _incrementKgMeta,
        incrementKg.isAcceptableOrUnknown(
          data['increment_kg']!,
          _incrementKgMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_incrementKgMeta);
    }
    if (data.containsKey('is_unilateral')) {
      context.handle(
        _isUnilateralMeta,
        isUnilateral.isAcceptableOrUnknown(
          data['is_unilateral']!,
          _isUnilateralMeta,
        ),
      );
    }
    if (data.containsKey('is_bodyweight')) {
      context.handle(
        _isBodyweightMeta,
        isBodyweight.isAcceptableOrUnknown(
          data['is_bodyweight']!,
          _isBodyweightMeta,
        ),
      );
    }
    if (data.containsKey('is_explosive')) {
      context.handle(
        _isExplosiveMeta,
        isExplosive.isAcceptableOrUnknown(
          data['is_explosive']!,
          _isExplosiveMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_custom')) {
      context.handle(
        _isCustomMeta,
        isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta),
      );
    }
    if (data.containsKey('archived')) {
      context.handle(
        _archivedMeta,
        archived.isAcceptableOrUnknown(data['archived']!, _archivedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      muscleGroup: $ExercisesTable.$convertermuscleGroup.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}muscle_group'],
        )!,
      ),
      role: $ExercisesTable.$converterrole.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}role'],
        )!,
      ),
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      )!,
      repRangeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_range_min'],
      )!,
      repRangeMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_range_max'],
      )!,
      incrementKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}increment_kg'],
      )!,
      isUnilateral: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_unilateral'],
      )!,
      isBodyweight: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_bodyweight'],
      )!,
      isExplosive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_explosive'],
      )!,
      primaryMuscle: $ExercisesTable.$converterprimaryMusclen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}primary_muscle'],
        ),
      ),
      secondaryMuscle: $ExercisesTable.$convertersecondaryMusclen.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}secondary_muscle'],
        ),
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isCustom: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_custom'],
      )!,
      archived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}archived'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MuscleGroup, String, String> $convertermuscleGroup =
      const EnumNameConverter<MuscleGroup>(MuscleGroup.values);
  static JsonTypeConverter2<ExerciseRole, String, String> $converterrole =
      const EnumNameConverter<ExerciseRole>(ExerciseRole.values);
  static JsonTypeConverter2<Muscle, String, String> $converterprimaryMuscle =
      const EnumNameConverter<Muscle>(Muscle.values);
  static JsonTypeConverter2<Muscle?, String?, String?>
  $converterprimaryMusclen = JsonTypeConverter2.asNullable(
    $converterprimaryMuscle,
  );
  static JsonTypeConverter2<Muscle, String, String> $convertersecondaryMuscle =
      const EnumNameConverter<Muscle>(Muscle.values);
  static JsonTypeConverter2<Muscle?, String?, String?>
  $convertersecondaryMusclen = JsonTypeConverter2.asNullable(
    $convertersecondaryMuscle,
  );
}

class ExerciseRow extends DataClass implements Insertable<ExerciseRow> {
  final DateTime updatedAt;
  final bool synced;

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  final bool deleted;
  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final ExerciseRole role;
  final int targetSets;
  final int repRangeMin;
  final int repRangeMax;
  final double incrementKg;

  /// Bulgarian split squats, single-arm rows: the logged set is per side.
  final bool isUnilateral;

  /// Weighted pull-ups / dips log *added* load, which can legitimately be 0.
  final bool isBodyweight;

  /// Power work (box jumps): excluded from hypertrophy volume and from
  /// auto-progression.
  final bool isExplosive;

  /// Fine-grained attribution for volume tracking. Primary gets a full set of
  /// credit, secondary half. Nullable so rows that predate the taxonomy load;
  /// resolve through `ExerciseMuscles` rather than reading these directly.
  final Muscle? primaryMuscle;
  final Muscle? secondaryMuscle;
  final String? notes;
  final bool isCustom;
  final bool archived;
  const ExerciseRow({
    required this.updatedAt,
    required this.synced,
    required this.deleted,
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.role,
    required this.targetSets,
    required this.repRangeMin,
    required this.repRangeMax,
    required this.incrementKg,
    required this.isUnilateral,
    required this.isBodyweight,
    required this.isExplosive,
    this.primaryMuscle,
    this.secondaryMuscle,
    this.notes,
    required this.isCustom,
    required this.archived,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    {
      map['muscle_group'] = Variable<String>(
        $ExercisesTable.$convertermuscleGroup.toSql(muscleGroup),
      );
    }
    {
      map['role'] = Variable<String>(
        $ExercisesTable.$converterrole.toSql(role),
      );
    }
    map['target_sets'] = Variable<int>(targetSets);
    map['rep_range_min'] = Variable<int>(repRangeMin);
    map['rep_range_max'] = Variable<int>(repRangeMax);
    map['increment_kg'] = Variable<double>(incrementKg);
    map['is_unilateral'] = Variable<bool>(isUnilateral);
    map['is_bodyweight'] = Variable<bool>(isBodyweight);
    map['is_explosive'] = Variable<bool>(isExplosive);
    if (!nullToAbsent || primaryMuscle != null) {
      map['primary_muscle'] = Variable<String>(
        $ExercisesTable.$converterprimaryMusclen.toSql(primaryMuscle),
      );
    }
    if (!nullToAbsent || secondaryMuscle != null) {
      map['secondary_muscle'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMusclen.toSql(secondaryMuscle),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_custom'] = Variable<bool>(isCustom);
    map['archived'] = Variable<bool>(archived);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
      id: Value(id),
      name: Value(name),
      muscleGroup: Value(muscleGroup),
      role: Value(role),
      targetSets: Value(targetSets),
      repRangeMin: Value(repRangeMin),
      repRangeMax: Value(repRangeMax),
      incrementKg: Value(incrementKg),
      isUnilateral: Value(isUnilateral),
      isBodyweight: Value(isBodyweight),
      isExplosive: Value(isExplosive),
      primaryMuscle: primaryMuscle == null && nullToAbsent
          ? const Value.absent()
          : Value(primaryMuscle),
      secondaryMuscle: secondaryMuscle == null && nullToAbsent
          ? const Value.absent()
          : Value(secondaryMuscle),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isCustom: Value(isCustom),
      archived: Value(archived),
    );
  }

  factory ExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      muscleGroup: $ExercisesTable.$convertermuscleGroup.fromJson(
        serializer.fromJson<String>(json['muscleGroup']),
      ),
      role: $ExercisesTable.$converterrole.fromJson(
        serializer.fromJson<String>(json['role']),
      ),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      repRangeMin: serializer.fromJson<int>(json['repRangeMin']),
      repRangeMax: serializer.fromJson<int>(json['repRangeMax']),
      incrementKg: serializer.fromJson<double>(json['incrementKg']),
      isUnilateral: serializer.fromJson<bool>(json['isUnilateral']),
      isBodyweight: serializer.fromJson<bool>(json['isBodyweight']),
      isExplosive: serializer.fromJson<bool>(json['isExplosive']),
      primaryMuscle: $ExercisesTable.$converterprimaryMusclen.fromJson(
        serializer.fromJson<String?>(json['primaryMuscle']),
      ),
      secondaryMuscle: $ExercisesTable.$convertersecondaryMusclen.fromJson(
        serializer.fromJson<String?>(json['secondaryMuscle']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      archived: serializer.fromJson<bool>(json['archived']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'muscleGroup': serializer.toJson<String>(
        $ExercisesTable.$convertermuscleGroup.toJson(muscleGroup),
      ),
      'role': serializer.toJson<String>(
        $ExercisesTable.$converterrole.toJson(role),
      ),
      'targetSets': serializer.toJson<int>(targetSets),
      'repRangeMin': serializer.toJson<int>(repRangeMin),
      'repRangeMax': serializer.toJson<int>(repRangeMax),
      'incrementKg': serializer.toJson<double>(incrementKg),
      'isUnilateral': serializer.toJson<bool>(isUnilateral),
      'isBodyweight': serializer.toJson<bool>(isBodyweight),
      'isExplosive': serializer.toJson<bool>(isExplosive),
      'primaryMuscle': serializer.toJson<String?>(
        $ExercisesTable.$converterprimaryMusclen.toJson(primaryMuscle),
      ),
      'secondaryMuscle': serializer.toJson<String?>(
        $ExercisesTable.$convertersecondaryMusclen.toJson(secondaryMuscle),
      ),
      'notes': serializer.toJson<String?>(notes),
      'isCustom': serializer.toJson<bool>(isCustom),
      'archived': serializer.toJson<bool>(archived),
    };
  }

  ExerciseRow copyWith({
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
    String? id,
    String? name,
    MuscleGroup? muscleGroup,
    ExerciseRole? role,
    int? targetSets,
    int? repRangeMin,
    int? repRangeMax,
    double? incrementKg,
    bool? isUnilateral,
    bool? isBodyweight,
    bool? isExplosive,
    Value<Muscle?> primaryMuscle = const Value.absent(),
    Value<Muscle?> secondaryMuscle = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isCustom,
    bool? archived,
  }) => ExerciseRow(
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    name: name ?? this.name,
    muscleGroup: muscleGroup ?? this.muscleGroup,
    role: role ?? this.role,
    targetSets: targetSets ?? this.targetSets,
    repRangeMin: repRangeMin ?? this.repRangeMin,
    repRangeMax: repRangeMax ?? this.repRangeMax,
    incrementKg: incrementKg ?? this.incrementKg,
    isUnilateral: isUnilateral ?? this.isUnilateral,
    isBodyweight: isBodyweight ?? this.isBodyweight,
    isExplosive: isExplosive ?? this.isExplosive,
    primaryMuscle: primaryMuscle.present
        ? primaryMuscle.value
        : this.primaryMuscle,
    secondaryMuscle: secondaryMuscle.present
        ? secondaryMuscle.value
        : this.secondaryMuscle,
    notes: notes.present ? notes.value : this.notes,
    isCustom: isCustom ?? this.isCustom,
    archived: archived ?? this.archived,
  );
  ExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return ExerciseRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      muscleGroup: data.muscleGroup.present
          ? data.muscleGroup.value
          : this.muscleGroup,
      role: data.role.present ? data.role.value : this.role,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      repRangeMin: data.repRangeMin.present
          ? data.repRangeMin.value
          : this.repRangeMin,
      repRangeMax: data.repRangeMax.present
          ? data.repRangeMax.value
          : this.repRangeMax,
      incrementKg: data.incrementKg.present
          ? data.incrementKg.value
          : this.incrementKg,
      isUnilateral: data.isUnilateral.present
          ? data.isUnilateral.value
          : this.isUnilateral,
      isBodyweight: data.isBodyweight.present
          ? data.isBodyweight.value
          : this.isBodyweight,
      isExplosive: data.isExplosive.present
          ? data.isExplosive.value
          : this.isExplosive,
      primaryMuscle: data.primaryMuscle.present
          ? data.primaryMuscle.value
          : this.primaryMuscle,
      secondaryMuscle: data.secondaryMuscle.present
          ? data.secondaryMuscle.value
          : this.secondaryMuscle,
      notes: data.notes.present ? data.notes.value : this.notes,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      archived: data.archived.present ? data.archived.value : this.archived,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('role: $role, ')
          ..write('targetSets: $targetSets, ')
          ..write('repRangeMin: $repRangeMin, ')
          ..write('repRangeMax: $repRangeMax, ')
          ..write('incrementKg: $incrementKg, ')
          ..write('isUnilateral: $isUnilateral, ')
          ..write('isBodyweight: $isBodyweight, ')
          ..write('isExplosive: $isExplosive, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMuscle: $secondaryMuscle, ')
          ..write('notes: $notes, ')
          ..write('isCustom: $isCustom, ')
          ..write('archived: $archived')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    synced,
    deleted,
    id,
    name,
    muscleGroup,
    role,
    targetSets,
    repRangeMin,
    repRangeMax,
    incrementKg,
    isUnilateral,
    isBodyweight,
    isExplosive,
    primaryMuscle,
    secondaryMuscle,
    notes,
    isCustom,
    archived,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRow &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.name == this.name &&
          other.muscleGroup == this.muscleGroup &&
          other.role == this.role &&
          other.targetSets == this.targetSets &&
          other.repRangeMin == this.repRangeMin &&
          other.repRangeMax == this.repRangeMax &&
          other.incrementKg == this.incrementKg &&
          other.isUnilateral == this.isUnilateral &&
          other.isBodyweight == this.isBodyweight &&
          other.isExplosive == this.isExplosive &&
          other.primaryMuscle == this.primaryMuscle &&
          other.secondaryMuscle == this.secondaryMuscle &&
          other.notes == this.notes &&
          other.isCustom == this.isCustom &&
          other.archived == this.archived);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseRow> {
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> name;
  final Value<MuscleGroup> muscleGroup;
  final Value<ExerciseRole> role;
  final Value<int> targetSets;
  final Value<int> repRangeMin;
  final Value<int> repRangeMax;
  final Value<double> incrementKg;
  final Value<bool> isUnilateral;
  final Value<bool> isBodyweight;
  final Value<bool> isExplosive;
  final Value<Muscle?> primaryMuscle;
  final Value<Muscle?> secondaryMuscle;
  final Value<String?> notes;
  final Value<bool> isCustom;
  final Value<bool> archived;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.muscleGroup = const Value.absent(),
    this.role = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.repRangeMin = const Value.absent(),
    this.repRangeMax = const Value.absent(),
    this.incrementKg = const Value.absent(),
    this.isUnilateral = const Value.absent(),
    this.isBodyweight = const Value.absent(),
    this.isExplosive = const Value.absent(),
    this.primaryMuscle = const Value.absent(),
    this.secondaryMuscle = const Value.absent(),
    this.notes = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    required String id,
    required String name,
    required MuscleGroup muscleGroup,
    required ExerciseRole role,
    required int targetSets,
    required int repRangeMin,
    required int repRangeMax,
    required double incrementKg,
    this.isUnilateral = const Value.absent(),
    this.isBodyweight = const Value.absent(),
    this.isExplosive = const Value.absent(),
    this.primaryMuscle = const Value.absent(),
    this.secondaryMuscle = const Value.absent(),
    this.notes = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.archived = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       muscleGroup = Value(muscleGroup),
       role = Value(role),
       targetSets = Value(targetSets),
       repRangeMin = Value(repRangeMin),
       repRangeMax = Value(repRangeMax),
       incrementKg = Value(incrementKg);
  static Insertable<ExerciseRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? muscleGroup,
    Expression<String>? role,
    Expression<int>? targetSets,
    Expression<int>? repRangeMin,
    Expression<int>? repRangeMax,
    Expression<double>? incrementKg,
    Expression<bool>? isUnilateral,
    Expression<bool>? isBodyweight,
    Expression<bool>? isExplosive,
    Expression<String>? primaryMuscle,
    Expression<String>? secondaryMuscle,
    Expression<String>? notes,
    Expression<bool>? isCustom,
    Expression<bool>? archived,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (muscleGroup != null) 'muscle_group': muscleGroup,
      if (role != null) 'role': role,
      if (targetSets != null) 'target_sets': targetSets,
      if (repRangeMin != null) 'rep_range_min': repRangeMin,
      if (repRangeMax != null) 'rep_range_max': repRangeMax,
      if (incrementKg != null) 'increment_kg': incrementKg,
      if (isUnilateral != null) 'is_unilateral': isUnilateral,
      if (isBodyweight != null) 'is_bodyweight': isBodyweight,
      if (isExplosive != null) 'is_explosive': isExplosive,
      if (primaryMuscle != null) 'primary_muscle': primaryMuscle,
      if (secondaryMuscle != null) 'secondary_muscle': secondaryMuscle,
      if (notes != null) 'notes': notes,
      if (isCustom != null) 'is_custom': isCustom,
      if (archived != null) 'archived': archived,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? name,
    Value<MuscleGroup>? muscleGroup,
    Value<ExerciseRole>? role,
    Value<int>? targetSets,
    Value<int>? repRangeMin,
    Value<int>? repRangeMax,
    Value<double>? incrementKg,
    Value<bool>? isUnilateral,
    Value<bool>? isBodyweight,
    Value<bool>? isExplosive,
    Value<Muscle?>? primaryMuscle,
    Value<Muscle?>? secondaryMuscle,
    Value<String?>? notes,
    Value<bool>? isCustom,
    Value<bool>? archived,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      role: role ?? this.role,
      targetSets: targetSets ?? this.targetSets,
      repRangeMin: repRangeMin ?? this.repRangeMin,
      repRangeMax: repRangeMax ?? this.repRangeMax,
      incrementKg: incrementKg ?? this.incrementKg,
      isUnilateral: isUnilateral ?? this.isUnilateral,
      isBodyweight: isBodyweight ?? this.isBodyweight,
      isExplosive: isExplosive ?? this.isExplosive,
      primaryMuscle: primaryMuscle ?? this.primaryMuscle,
      secondaryMuscle: secondaryMuscle ?? this.secondaryMuscle,
      notes: notes ?? this.notes,
      isCustom: isCustom ?? this.isCustom,
      archived: archived ?? this.archived,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (muscleGroup.present) {
      map['muscle_group'] = Variable<String>(
        $ExercisesTable.$convertermuscleGroup.toSql(muscleGroup.value),
      );
    }
    if (role.present) {
      map['role'] = Variable<String>(
        $ExercisesTable.$converterrole.toSql(role.value),
      );
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (repRangeMin.present) {
      map['rep_range_min'] = Variable<int>(repRangeMin.value);
    }
    if (repRangeMax.present) {
      map['rep_range_max'] = Variable<int>(repRangeMax.value);
    }
    if (incrementKg.present) {
      map['increment_kg'] = Variable<double>(incrementKg.value);
    }
    if (isUnilateral.present) {
      map['is_unilateral'] = Variable<bool>(isUnilateral.value);
    }
    if (isBodyweight.present) {
      map['is_bodyweight'] = Variable<bool>(isBodyweight.value);
    }
    if (isExplosive.present) {
      map['is_explosive'] = Variable<bool>(isExplosive.value);
    }
    if (primaryMuscle.present) {
      map['primary_muscle'] = Variable<String>(
        $ExercisesTable.$converterprimaryMusclen.toSql(primaryMuscle.value),
      );
    }
    if (secondaryMuscle.present) {
      map['secondary_muscle'] = Variable<String>(
        $ExercisesTable.$convertersecondaryMusclen.toSql(secondaryMuscle.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (archived.present) {
      map['archived'] = Variable<bool>(archived.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('muscleGroup: $muscleGroup, ')
          ..write('role: $role, ')
          ..write('targetSets: $targetSets, ')
          ..write('repRangeMin: $repRangeMin, ')
          ..write('repRangeMax: $repRangeMax, ')
          ..write('incrementKg: $incrementKg, ')
          ..write('isUnilateral: $isUnilateral, ')
          ..write('isBodyweight: $isBodyweight, ')
          ..write('isExplosive: $isExplosive, ')
          ..write('primaryMuscle: $primaryMuscle, ')
          ..write('secondaryMuscle: $secondaryMuscle, ')
          ..write('notes: $notes, ')
          ..write('isCustom: $isCustom, ')
          ..write('archived: $archived, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplatesTable extends Templates
    with TableInfo<$TemplatesTable, TemplateRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplatesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weekdayMeta = const VerificationMeta(
    'weekday',
  );
  @override
  late final GeneratedColumn<int> weekday = GeneratedColumn<int>(
    'weekday',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cardioLabelMeta = const VerificationMeta(
    'cardioLabel',
  );
  @override
  late final GeneratedColumn<String> cardioLabel = GeneratedColumn<String>(
    'cardio_label',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accentHexMeta = const VerificationMeta(
    'accentHex',
  );
  @override
  late final GeneratedColumn<String> accentHex = GeneratedColumn<String>(
    'accent_hex',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    synced,
    deleted,
    id,
    name,
    weekday,
    cardioLabel,
    accentHex,
    orderIndex,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('weekday')) {
      context.handle(
        _weekdayMeta,
        weekday.isAcceptableOrUnknown(data['weekday']!, _weekdayMeta),
      );
    }
    if (data.containsKey('cardio_label')) {
      context.handle(
        _cardioLabelMeta,
        cardioLabel.isAcceptableOrUnknown(
          data['cardio_label']!,
          _cardioLabelMeta,
        ),
      );
    }
    if (data.containsKey('accent_hex')) {
      context.handle(
        _accentHexMeta,
        accentHex.isAcceptableOrUnknown(data['accent_hex']!, _accentHexMeta),
      );
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      weekday: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday'],
      ),
      cardioLabel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cardio_label'],
      ),
      accentHex: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}accent_hex'],
      ),
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
    );
  }

  @override
  $TemplatesTable createAlias(String alias) {
    return $TemplatesTable(attachedDatabase, alias);
  }
}

class TemplateRow extends DataClass implements Insertable<TemplateRow> {
  final DateTime updatedAt;
  final bool synced;

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  final bool deleted;
  final String id;
  final String name;

  /// 1 = Mon … 7 = Sun, matching [DateTime.weekday]. Null for a template the
  /// user has taken off the weekly schedule.
  final int? weekday;

  /// "Rope 5 min", "HIIT bike 15 min" — the cardio prescription for the day.
  final String? cardioLabel;
  final String? accentHex;
  final int orderIndex;
  const TemplateRow({
    required this.updatedAt,
    required this.synced,
    required this.deleted,
    required this.id,
    required this.name,
    this.weekday,
    this.cardioLabel,
    this.accentHex,
    required this.orderIndex,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || weekday != null) {
      map['weekday'] = Variable<int>(weekday);
    }
    if (!nullToAbsent || cardioLabel != null) {
      map['cardio_label'] = Variable<String>(cardioLabel);
    }
    if (!nullToAbsent || accentHex != null) {
      map['accent_hex'] = Variable<String>(accentHex);
    }
    map['order_index'] = Variable<int>(orderIndex);
    return map;
  }

  TemplatesCompanion toCompanion(bool nullToAbsent) {
    return TemplatesCompanion(
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
      id: Value(id),
      name: Value(name),
      weekday: weekday == null && nullToAbsent
          ? const Value.absent()
          : Value(weekday),
      cardioLabel: cardioLabel == null && nullToAbsent
          ? const Value.absent()
          : Value(cardioLabel),
      accentHex: accentHex == null && nullToAbsent
          ? const Value.absent()
          : Value(accentHex),
      orderIndex: Value(orderIndex),
    );
  }

  factory TemplateRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      weekday: serializer.fromJson<int?>(json['weekday']),
      cardioLabel: serializer.fromJson<String?>(json['cardioLabel']),
      accentHex: serializer.fromJson<String?>(json['accentHex']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'weekday': serializer.toJson<int?>(weekday),
      'cardioLabel': serializer.toJson<String?>(cardioLabel),
      'accentHex': serializer.toJson<String?>(accentHex),
      'orderIndex': serializer.toJson<int>(orderIndex),
    };
  }

  TemplateRow copyWith({
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
    String? id,
    String? name,
    Value<int?> weekday = const Value.absent(),
    Value<String?> cardioLabel = const Value.absent(),
    Value<String?> accentHex = const Value.absent(),
    int? orderIndex,
  }) => TemplateRow(
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    name: name ?? this.name,
    weekday: weekday.present ? weekday.value : this.weekday,
    cardioLabel: cardioLabel.present ? cardioLabel.value : this.cardioLabel,
    accentHex: accentHex.present ? accentHex.value : this.accentHex,
    orderIndex: orderIndex ?? this.orderIndex,
  );
  TemplateRow copyWithCompanion(TemplatesCompanion data) {
    return TemplateRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      weekday: data.weekday.present ? data.weekday.value : this.weekday,
      cardioLabel: data.cardioLabel.present
          ? data.cardioLabel.value
          : this.cardioLabel,
      accentHex: data.accentHex.present ? data.accentHex.value : this.accentHex,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weekday: $weekday, ')
          ..write('cardioLabel: $cardioLabel, ')
          ..write('accentHex: $accentHex, ')
          ..write('orderIndex: $orderIndex')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    synced,
    deleted,
    id,
    name,
    weekday,
    cardioLabel,
    accentHex,
    orderIndex,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateRow &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.name == this.name &&
          other.weekday == this.weekday &&
          other.cardioLabel == this.cardioLabel &&
          other.accentHex == this.accentHex &&
          other.orderIndex == this.orderIndex);
}

class TemplatesCompanion extends UpdateCompanion<TemplateRow> {
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> name;
  final Value<int?> weekday;
  final Value<String?> cardioLabel;
  final Value<String?> accentHex;
  final Value<int> orderIndex;
  final Value<int> rowid;
  const TemplatesCompanion({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.weekday = const Value.absent(),
    this.cardioLabel = const Value.absent(),
    this.accentHex = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplatesCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    required String id,
    required String name,
    this.weekday = const Value.absent(),
    this.cardioLabel = const Value.absent(),
    this.accentHex = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<TemplateRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? weekday,
    Expression<String>? cardioLabel,
    Expression<String>? accentHex,
    Expression<int>? orderIndex,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (weekday != null) 'weekday': weekday,
      if (cardioLabel != null) 'cardio_label': cardioLabel,
      if (accentHex != null) 'accent_hex': accentHex,
      if (orderIndex != null) 'order_index': orderIndex,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplatesCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? name,
    Value<int?>? weekday,
    Value<String?>? cardioLabel,
    Value<String?>? accentHex,
    Value<int>? orderIndex,
    Value<int>? rowid,
  }) {
    return TemplatesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      name: name ?? this.name,
      weekday: weekday ?? this.weekday,
      cardioLabel: cardioLabel ?? this.cardioLabel,
      accentHex: accentHex ?? this.accentHex,
      orderIndex: orderIndex ?? this.orderIndex,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (weekday.present) {
      map['weekday'] = Variable<int>(weekday.value);
    }
    if (cardioLabel.present) {
      map['cardio_label'] = Variable<String>(cardioLabel.value);
    }
    if (accentHex.present) {
      map['accent_hex'] = Variable<String>(accentHex.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplatesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('weekday: $weekday, ')
          ..write('cardioLabel: $cardioLabel, ')
          ..write('accentHex: $accentHex, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TemplateExercisesTable extends TemplateExercises
    with TableInfo<$TemplateExercisesTable, TemplateExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TemplateExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES templates (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _setsOverrideMeta = const VerificationMeta(
    'setsOverride',
  );
  @override
  late final GeneratedColumn<int> setsOverride = GeneratedColumn<int>(
    'sets_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repMinOverrideMeta = const VerificationMeta(
    'repMinOverride',
  );
  @override
  late final GeneratedColumn<int> repMinOverride = GeneratedColumn<int>(
    'rep_min_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _repMaxOverrideMeta = const VerificationMeta(
    'repMaxOverride',
  );
  @override
  late final GeneratedColumn<int> repMaxOverride = GeneratedColumn<int>(
    'rep_max_override',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supersetGroupMeta = const VerificationMeta(
    'supersetGroup',
  );
  @override
  late final GeneratedColumn<int> supersetGroup = GeneratedColumn<int>(
    'superset_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    synced,
    deleted,
    id,
    templateId,
    exerciseId,
    orderIndex,
    setsOverride,
    repMinOverride,
    repMaxOverride,
    supersetGroup,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'template_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<TemplateExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('sets_override')) {
      context.handle(
        _setsOverrideMeta,
        setsOverride.isAcceptableOrUnknown(
          data['sets_override']!,
          _setsOverrideMeta,
        ),
      );
    }
    if (data.containsKey('rep_min_override')) {
      context.handle(
        _repMinOverrideMeta,
        repMinOverride.isAcceptableOrUnknown(
          data['rep_min_override']!,
          _repMinOverrideMeta,
        ),
      );
    }
    if (data.containsKey('rep_max_override')) {
      context.handle(
        _repMaxOverrideMeta,
        repMaxOverride.isAcceptableOrUnknown(
          data['rep_max_override']!,
          _repMaxOverrideMeta,
        ),
      );
    }
    if (data.containsKey('superset_group')) {
      context.handle(
        _supersetGroupMeta,
        supersetGroup.isAcceptableOrUnknown(
          data['superset_group']!,
          _supersetGroupMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TemplateExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TemplateExerciseRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      setsOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sets_override'],
      ),
      repMinOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_min_override'],
      ),
      repMaxOverride: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_max_override'],
      ),
      supersetGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superset_group'],
      ),
    );
  }

  @override
  $TemplateExercisesTable createAlias(String alias) {
    return $TemplateExercisesTable(attachedDatabase, alias);
  }
}

class TemplateExerciseRow extends DataClass
    implements Insertable<TemplateExerciseRow> {
  final DateTime updatedAt;
  final bool synced;

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  final bool deleted;
  final String id;
  final String templateId;
  final String exerciseId;
  final int orderIndex;

  /// Overrides the exercise default when a template wants a different volume
  /// (e.g. calf raises are 4 sets on legs day, 3 elsewhere).
  final int? setsOverride;

  /// Per-day rep range, when the program prescribes something other than the
  /// exercise default (Leg Press 8–12 on Legs A but 12–15 on Legs B).
  final int? repMinOverride;
  final int? repMaxOverride;

  /// Consecutive exercises sharing a group number are a superset: you
  /// alternate between them and only rest after the last one. Null means the
  /// exercise stands alone.
  final int? supersetGroup;
  const TemplateExerciseRow({
    required this.updatedAt,
    required this.synced,
    required this.deleted,
    required this.id,
    required this.templateId,
    required this.exerciseId,
    required this.orderIndex,
    this.setsOverride,
    this.repMinOverride,
    this.repMaxOverride,
    this.supersetGroup,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['template_id'] = Variable<String>(templateId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order_index'] = Variable<int>(orderIndex);
    if (!nullToAbsent || setsOverride != null) {
      map['sets_override'] = Variable<int>(setsOverride);
    }
    if (!nullToAbsent || repMinOverride != null) {
      map['rep_min_override'] = Variable<int>(repMinOverride);
    }
    if (!nullToAbsent || repMaxOverride != null) {
      map['rep_max_override'] = Variable<int>(repMaxOverride);
    }
    if (!nullToAbsent || supersetGroup != null) {
      map['superset_group'] = Variable<int>(supersetGroup);
    }
    return map;
  }

  TemplateExercisesCompanion toCompanion(bool nullToAbsent) {
    return TemplateExercisesCompanion(
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
      id: Value(id),
      templateId: Value(templateId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(orderIndex),
      setsOverride: setsOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(setsOverride),
      repMinOverride: repMinOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(repMinOverride),
      repMaxOverride: repMaxOverride == null && nullToAbsent
          ? const Value.absent()
          : Value(repMaxOverride),
      supersetGroup: supersetGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroup),
    );
  }

  factory TemplateExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TemplateExerciseRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      templateId: serializer.fromJson<String>(json['templateId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      setsOverride: serializer.fromJson<int?>(json['setsOverride']),
      repMinOverride: serializer.fromJson<int?>(json['repMinOverride']),
      repMaxOverride: serializer.fromJson<int?>(json['repMaxOverride']),
      supersetGroup: serializer.fromJson<int?>(json['supersetGroup']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'templateId': serializer.toJson<String>(templateId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'setsOverride': serializer.toJson<int?>(setsOverride),
      'repMinOverride': serializer.toJson<int?>(repMinOverride),
      'repMaxOverride': serializer.toJson<int?>(repMaxOverride),
      'supersetGroup': serializer.toJson<int?>(supersetGroup),
    };
  }

  TemplateExerciseRow copyWith({
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
    String? id,
    String? templateId,
    String? exerciseId,
    int? orderIndex,
    Value<int?> setsOverride = const Value.absent(),
    Value<int?> repMinOverride = const Value.absent(),
    Value<int?> repMaxOverride = const Value.absent(),
    Value<int?> supersetGroup = const Value.absent(),
  }) => TemplateExerciseRow(
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderIndex: orderIndex ?? this.orderIndex,
    setsOverride: setsOverride.present ? setsOverride.value : this.setsOverride,
    repMinOverride: repMinOverride.present
        ? repMinOverride.value
        : this.repMinOverride,
    repMaxOverride: repMaxOverride.present
        ? repMaxOverride.value
        : this.repMaxOverride,
    supersetGroup: supersetGroup.present
        ? supersetGroup.value
        : this.supersetGroup,
  );
  TemplateExerciseRow copyWithCompanion(TemplateExercisesCompanion data) {
    return TemplateExerciseRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      setsOverride: data.setsOverride.present
          ? data.setsOverride.value
          : this.setsOverride,
      repMinOverride: data.repMinOverride.present
          ? data.repMinOverride.value
          : this.repMinOverride,
      repMaxOverride: data.repMaxOverride.present
          ? data.repMaxOverride.value
          : this.repMaxOverride,
      supersetGroup: data.supersetGroup.present
          ? data.supersetGroup.value
          : this.supersetGroup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TemplateExerciseRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('setsOverride: $setsOverride, ')
          ..write('repMinOverride: $repMinOverride, ')
          ..write('repMaxOverride: $repMaxOverride, ')
          ..write('supersetGroup: $supersetGroup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    synced,
    deleted,
    id,
    templateId,
    exerciseId,
    orderIndex,
    setsOverride,
    repMinOverride,
    repMaxOverride,
    supersetGroup,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TemplateExerciseRow &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.exerciseId == this.exerciseId &&
          other.orderIndex == this.orderIndex &&
          other.setsOverride == this.setsOverride &&
          other.repMinOverride == this.repMinOverride &&
          other.repMaxOverride == this.repMaxOverride &&
          other.supersetGroup == this.supersetGroup);
}

class TemplateExercisesCompanion extends UpdateCompanion<TemplateExerciseRow> {
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> templateId;
  final Value<String> exerciseId;
  final Value<int> orderIndex;
  final Value<int?> setsOverride;
  final Value<int?> repMinOverride;
  final Value<int?> repMaxOverride;
  final Value<int?> supersetGroup;
  final Value<int> rowid;
  const TemplateExercisesCompanion({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.setsOverride = const Value.absent(),
    this.repMinOverride = const Value.absent(),
    this.repMaxOverride = const Value.absent(),
    this.supersetGroup = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TemplateExercisesCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    required String id,
    required String templateId,
    required String exerciseId,
    required int orderIndex,
    this.setsOverride = const Value.absent(),
    this.repMinOverride = const Value.absent(),
    this.repMaxOverride = const Value.absent(),
    this.supersetGroup = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       templateId = Value(templateId),
       exerciseId = Value(exerciseId),
       orderIndex = Value(orderIndex);
  static Insertable<TemplateExerciseRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? templateId,
    Expression<String>? exerciseId,
    Expression<int>? orderIndex,
    Expression<int>? setsOverride,
    Expression<int>? repMinOverride,
    Expression<int>? repMaxOverride,
    Expression<int>? supersetGroup,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (setsOverride != null) 'sets_override': setsOverride,
      if (repMinOverride != null) 'rep_min_override': repMinOverride,
      if (repMaxOverride != null) 'rep_max_override': repMaxOverride,
      if (supersetGroup != null) 'superset_group': supersetGroup,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TemplateExercisesCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? templateId,
    Value<String>? exerciseId,
    Value<int>? orderIndex,
    Value<int?>? setsOverride,
    Value<int?>? repMinOverride,
    Value<int?>? repMaxOverride,
    Value<int?>? supersetGroup,
    Value<int>? rowid,
  }) {
    return TemplateExercisesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      setsOverride: setsOverride ?? this.setsOverride,
      repMinOverride: repMinOverride ?? this.repMinOverride,
      repMaxOverride: repMaxOverride ?? this.repMaxOverride,
      supersetGroup: supersetGroup ?? this.supersetGroup,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (setsOverride.present) {
      map['sets_override'] = Variable<int>(setsOverride.value);
    }
    if (repMinOverride.present) {
      map['rep_min_override'] = Variable<int>(repMinOverride.value);
    }
    if (repMaxOverride.present) {
      map['rep_max_override'] = Variable<int>(repMaxOverride.value);
    }
    if (supersetGroup.present) {
      map['superset_group'] = Variable<int>(supersetGroup.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TemplateExercisesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('setsOverride: $setsOverride, ')
          ..write('repMinOverride: $repMinOverride, ')
          ..write('repMaxOverride: $repMaxOverride, ')
          ..write('supersetGroup: $supersetGroup, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionsTable extends Sessions
    with TableInfo<$SessionsTable, SessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<String> templateId = GeneratedColumn<String>(
    'template_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _templateNameMeta = const VerificationMeta(
    'templateName',
  );
  @override
  late final GeneratedColumn<String> templateName = GeneratedColumn<String>(
    'template_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _durationMinMeta = const VerificationMeta(
    'durationMin',
  );
  @override
  late final GeneratedColumn<int> durationMin = GeneratedColumn<int>(
    'duration_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _tonnageKgMeta = const VerificationMeta(
    'tonnageKg',
  );
  @override
  late final GeneratedColumn<double> tonnageKg = GeneratedColumn<double>(
    'tonnage_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalSetsMeta = const VerificationMeta(
    'totalSets',
  );
  @override
  late final GeneratedColumn<int> totalSets = GeneratedColumn<int>(
    'total_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _cardioDoneMeta = const VerificationMeta(
    'cardioDone',
  );
  @override
  late final GeneratedColumn<bool> cardioDone = GeneratedColumn<bool>(
    'cardio_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("cardio_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _saunaDoneMeta = const VerificationMeta(
    'saunaDone',
  );
  @override
  late final GeneratedColumn<bool> saunaDone = GeneratedColumn<bool>(
    'sauna_done',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sauna_done" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCompleteMeta = const VerificationMeta(
    'isComplete',
  );
  @override
  late final GeneratedColumn<bool> isComplete = GeneratedColumn<bool>(
    'is_complete',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_complete" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _durationSuspectMeta = const VerificationMeta(
    'durationSuspect',
  );
  @override
  late final GeneratedColumn<bool> durationSuspect = GeneratedColumn<bool>(
    'duration_suspect',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("duration_suspect" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    synced,
    deleted,
    id,
    date,
    templateId,
    templateName,
    startedAt,
    endedAt,
    durationMin,
    tonnageKg,
    totalSets,
    cardioDone,
    saunaDone,
    notes,
    isComplete,
    durationSuspect,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    }
    if (data.containsKey('template_name')) {
      context.handle(
        _templateNameMeta,
        templateName.isAcceptableOrUnknown(
          data['template_name']!,
          _templateNameMeta,
        ),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    if (data.containsKey('duration_min')) {
      context.handle(
        _durationMinMeta,
        durationMin.isAcceptableOrUnknown(
          data['duration_min']!,
          _durationMinMeta,
        ),
      );
    }
    if (data.containsKey('tonnage_kg')) {
      context.handle(
        _tonnageKgMeta,
        tonnageKg.isAcceptableOrUnknown(data['tonnage_kg']!, _tonnageKgMeta),
      );
    }
    if (data.containsKey('total_sets')) {
      context.handle(
        _totalSetsMeta,
        totalSets.isAcceptableOrUnknown(data['total_sets']!, _totalSetsMeta),
      );
    }
    if (data.containsKey('cardio_done')) {
      context.handle(
        _cardioDoneMeta,
        cardioDone.isAcceptableOrUnknown(data['cardio_done']!, _cardioDoneMeta),
      );
    }
    if (data.containsKey('sauna_done')) {
      context.handle(
        _saunaDoneMeta,
        saunaDone.isAcceptableOrUnknown(data['sauna_done']!, _saunaDoneMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_complete')) {
      context.handle(
        _isCompleteMeta,
        isComplete.isAcceptableOrUnknown(data['is_complete']!, _isCompleteMeta),
      );
    }
    if (data.containsKey('duration_suspect')) {
      context.handle(
        _durationSuspectMeta,
        durationSuspect.isAcceptableOrUnknown(
          data['duration_suspect']!,
          _durationSuspectMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_id'],
      ),
      templateName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}template_name'],
      ),
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
      durationMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_min'],
      )!,
      tonnageKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tonnage_kg'],
      )!,
      totalSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_sets'],
      )!,
      cardioDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}cardio_done'],
      )!,
      saunaDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sauna_done'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isComplete: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_complete'],
      )!,
      durationSuspect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}duration_suspect'],
      )!,
    );
  }

  @override
  $SessionsTable createAlias(String alias) {
    return $SessionsTable(attachedDatabase, alias);
  }
}

class SessionRow extends DataClass implements Insertable<SessionRow> {
  final DateTime updatedAt;
  final bool synced;

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  final bool deleted;
  final String id;

  /// Local calendar day, normalised to midnight — the key for the heatmap.
  final DateTime date;
  final String? templateId;
  final String? templateName;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationMin;

  /// Total kg lifted, denormalised at finish time so history lists stay cheap.
  final double tonnageKg;
  final int totalSets;
  final bool cardioDone;
  final bool saunaDone;
  final String? notes;
  final bool isComplete;

  /// True when the wall-clock duration was implausible (>240 min — e.g. the
  /// app was left open overnight) and `durationMin` was capped.
  final bool durationSuspect;
  const SessionRow({
    required this.updatedAt,
    required this.synced,
    required this.deleted,
    required this.id,
    required this.date,
    this.templateId,
    this.templateName,
    required this.startedAt,
    this.endedAt,
    required this.durationMin,
    required this.tonnageKg,
    required this.totalSets,
    required this.cardioDone,
    required this.saunaDone,
    this.notes,
    required this.isComplete,
    required this.durationSuspect,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || templateId != null) {
      map['template_id'] = Variable<String>(templateId);
    }
    if (!nullToAbsent || templateName != null) {
      map['template_name'] = Variable<String>(templateName);
    }
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    map['duration_min'] = Variable<int>(durationMin);
    map['tonnage_kg'] = Variable<double>(tonnageKg);
    map['total_sets'] = Variable<int>(totalSets);
    map['cardio_done'] = Variable<bool>(cardioDone);
    map['sauna_done'] = Variable<bool>(saunaDone);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_complete'] = Variable<bool>(isComplete);
    map['duration_suspect'] = Variable<bool>(durationSuspect);
    return map;
  }

  SessionsCompanion toCompanion(bool nullToAbsent) {
    return SessionsCompanion(
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
      id: Value(id),
      date: Value(date),
      templateId: templateId == null && nullToAbsent
          ? const Value.absent()
          : Value(templateId),
      templateName: templateName == null && nullToAbsent
          ? const Value.absent()
          : Value(templateName),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      durationMin: Value(durationMin),
      tonnageKg: Value(tonnageKg),
      totalSets: Value(totalSets),
      cardioDone: Value(cardioDone),
      saunaDone: Value(saunaDone),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isComplete: Value(isComplete),
      durationSuspect: Value(durationSuspect),
    );
  }

  factory SessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      templateId: serializer.fromJson<String?>(json['templateId']),
      templateName: serializer.fromJson<String?>(json['templateName']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      durationMin: serializer.fromJson<int>(json['durationMin']),
      tonnageKg: serializer.fromJson<double>(json['tonnageKg']),
      totalSets: serializer.fromJson<int>(json['totalSets']),
      cardioDone: serializer.fromJson<bool>(json['cardioDone']),
      saunaDone: serializer.fromJson<bool>(json['saunaDone']),
      notes: serializer.fromJson<String?>(json['notes']),
      isComplete: serializer.fromJson<bool>(json['isComplete']),
      durationSuspect: serializer.fromJson<bool>(json['durationSuspect']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'templateId': serializer.toJson<String?>(templateId),
      'templateName': serializer.toJson<String?>(templateName),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'durationMin': serializer.toJson<int>(durationMin),
      'tonnageKg': serializer.toJson<double>(tonnageKg),
      'totalSets': serializer.toJson<int>(totalSets),
      'cardioDone': serializer.toJson<bool>(cardioDone),
      'saunaDone': serializer.toJson<bool>(saunaDone),
      'notes': serializer.toJson<String?>(notes),
      'isComplete': serializer.toJson<bool>(isComplete),
      'durationSuspect': serializer.toJson<bool>(durationSuspect),
    };
  }

  SessionRow copyWith({
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
    String? id,
    DateTime? date,
    Value<String?> templateId = const Value.absent(),
    Value<String?> templateName = const Value.absent(),
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
    int? durationMin,
    double? tonnageKg,
    int? totalSets,
    bool? cardioDone,
    bool? saunaDone,
    Value<String?> notes = const Value.absent(),
    bool? isComplete,
    bool? durationSuspect,
  }) => SessionRow(
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    date: date ?? this.date,
    templateId: templateId.present ? templateId.value : this.templateId,
    templateName: templateName.present ? templateName.value : this.templateName,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
    durationMin: durationMin ?? this.durationMin,
    tonnageKg: tonnageKg ?? this.tonnageKg,
    totalSets: totalSets ?? this.totalSets,
    cardioDone: cardioDone ?? this.cardioDone,
    saunaDone: saunaDone ?? this.saunaDone,
    notes: notes.present ? notes.value : this.notes,
    isComplete: isComplete ?? this.isComplete,
    durationSuspect: durationSuspect ?? this.durationSuspect,
  );
  SessionRow copyWithCompanion(SessionsCompanion data) {
    return SessionRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      templateName: data.templateName.present
          ? data.templateName.value
          : this.templateName,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      durationMin: data.durationMin.present
          ? data.durationMin.value
          : this.durationMin,
      tonnageKg: data.tonnageKg.present ? data.tonnageKg.value : this.tonnageKg,
      totalSets: data.totalSets.present ? data.totalSets.value : this.totalSets,
      cardioDone: data.cardioDone.present
          ? data.cardioDone.value
          : this.cardioDone,
      saunaDone: data.saunaDone.present ? data.saunaDone.value : this.saunaDone,
      notes: data.notes.present ? data.notes.value : this.notes,
      isComplete: data.isComplete.present
          ? data.isComplete.value
          : this.isComplete,
      durationSuspect: data.durationSuspect.present
          ? data.durationSuspect.value
          : this.durationSuspect,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('templateId: $templateId, ')
          ..write('templateName: $templateName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMin: $durationMin, ')
          ..write('tonnageKg: $tonnageKg, ')
          ..write('totalSets: $totalSets, ')
          ..write('cardioDone: $cardioDone, ')
          ..write('saunaDone: $saunaDone, ')
          ..write('notes: $notes, ')
          ..write('isComplete: $isComplete, ')
          ..write('durationSuspect: $durationSuspect')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    synced,
    deleted,
    id,
    date,
    templateId,
    templateName,
    startedAt,
    endedAt,
    durationMin,
    tonnageKg,
    totalSets,
    cardioDone,
    saunaDone,
    notes,
    isComplete,
    durationSuspect,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionRow &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.date == this.date &&
          other.templateId == this.templateId &&
          other.templateName == this.templateName &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.durationMin == this.durationMin &&
          other.tonnageKg == this.tonnageKg &&
          other.totalSets == this.totalSets &&
          other.cardioDone == this.cardioDone &&
          other.saunaDone == this.saunaDone &&
          other.notes == this.notes &&
          other.isComplete == this.isComplete &&
          other.durationSuspect == this.durationSuspect);
}

class SessionsCompanion extends UpdateCompanion<SessionRow> {
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String?> templateId;
  final Value<String?> templateName;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  final Value<int> durationMin;
  final Value<double> tonnageKg;
  final Value<int> totalSets;
  final Value<bool> cardioDone;
  final Value<bool> saunaDone;
  final Value<String?> notes;
  final Value<bool> isComplete;
  final Value<bool> durationSuspect;
  final Value<int> rowid;
  const SessionsCompanion({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.templateId = const Value.absent(),
    this.templateName = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.tonnageKg = const Value.absent(),
    this.totalSets = const Value.absent(),
    this.cardioDone = const Value.absent(),
    this.saunaDone = const Value.absent(),
    this.notes = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.durationSuspect = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionsCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    required String id,
    required DateTime date,
    this.templateId = const Value.absent(),
    this.templateName = const Value.absent(),
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
    this.durationMin = const Value.absent(),
    this.tonnageKg = const Value.absent(),
    this.totalSets = const Value.absent(),
    this.cardioDone = const Value.absent(),
    this.saunaDone = const Value.absent(),
    this.notes = const Value.absent(),
    this.isComplete = const Value.absent(),
    this.durationSuspect = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       startedAt = Value(startedAt);
  static Insertable<SessionRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? templateId,
    Expression<String>? templateName,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<int>? durationMin,
    Expression<double>? tonnageKg,
    Expression<int>? totalSets,
    Expression<bool>? cardioDone,
    Expression<bool>? saunaDone,
    Expression<String>? notes,
    Expression<bool>? isComplete,
    Expression<bool>? durationSuspect,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (templateId != null) 'template_id': templateId,
      if (templateName != null) 'template_name': templateName,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (durationMin != null) 'duration_min': durationMin,
      if (tonnageKg != null) 'tonnage_kg': tonnageKg,
      if (totalSets != null) 'total_sets': totalSets,
      if (cardioDone != null) 'cardio_done': cardioDone,
      if (saunaDone != null) 'sauna_done': saunaDone,
      if (notes != null) 'notes': notes,
      if (isComplete != null) 'is_complete': isComplete,
      if (durationSuspect != null) 'duration_suspect': durationSuspect,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<String>? id,
    Value<DateTime>? date,
    Value<String?>? templateId,
    Value<String?>? templateName,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
    Value<int>? durationMin,
    Value<double>? tonnageKg,
    Value<int>? totalSets,
    Value<bool>? cardioDone,
    Value<bool>? saunaDone,
    Value<String?>? notes,
    Value<bool>? isComplete,
    Value<bool>? durationSuspect,
    Value<int>? rowid,
  }) {
    return SessionsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      date: date ?? this.date,
      templateId: templateId ?? this.templateId,
      templateName: templateName ?? this.templateName,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      durationMin: durationMin ?? this.durationMin,
      tonnageKg: tonnageKg ?? this.tonnageKg,
      totalSets: totalSets ?? this.totalSets,
      cardioDone: cardioDone ?? this.cardioDone,
      saunaDone: saunaDone ?? this.saunaDone,
      notes: notes ?? this.notes,
      isComplete: isComplete ?? this.isComplete,
      durationSuspect: durationSuspect ?? this.durationSuspect,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<String>(templateId.value);
    }
    if (templateName.present) {
      map['template_name'] = Variable<String>(templateName.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (durationMin.present) {
      map['duration_min'] = Variable<int>(durationMin.value);
    }
    if (tonnageKg.present) {
      map['tonnage_kg'] = Variable<double>(tonnageKg.value);
    }
    if (totalSets.present) {
      map['total_sets'] = Variable<int>(totalSets.value);
    }
    if (cardioDone.present) {
      map['cardio_done'] = Variable<bool>(cardioDone.value);
    }
    if (saunaDone.present) {
      map['sauna_done'] = Variable<bool>(saunaDone.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isComplete.present) {
      map['is_complete'] = Variable<bool>(isComplete.value);
    }
    if (durationSuspect.present) {
      map['duration_suspect'] = Variable<bool>(durationSuspect.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('templateId: $templateId, ')
          ..write('templateName: $templateName, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('durationMin: $durationMin, ')
          ..write('tonnageKg: $tonnageKg, ')
          ..write('totalSets: $totalSets, ')
          ..write('cardioDone: $cardioDone, ')
          ..write('saunaDone: $saunaDone, ')
          ..write('notes: $notes, ')
          ..write('isComplete: $isComplete, ')
          ..write('durationSuspect: $durationSuspect, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SessionExercisesTable extends SessionExercises
    with TableInfo<$SessionExercisesTable, SessionExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SessionExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _orderIndexMeta = const VerificationMeta(
    'orderIndex',
  );
  @override
  late final GeneratedColumn<int> orderIndex = GeneratedColumn<int>(
    'order_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repRangeMinMeta = const VerificationMeta(
    'repRangeMin',
  );
  @override
  late final GeneratedColumn<int> repRangeMin = GeneratedColumn<int>(
    'rep_range_min',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repRangeMaxMeta = const VerificationMeta(
    'repRangeMax',
  );
  @override
  late final GeneratedColumn<int> repRangeMax = GeneratedColumn<int>(
    'rep_range_max',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedWeightKgMeta = const VerificationMeta(
    'suggestedWeightKg',
  );
  @override
  late final GeneratedColumn<double> suggestedWeightKg =
      GeneratedColumn<double>(
        'suggested_weight_kg',
        aliasedName,
        true,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _increaseFlaggedMeta = const VerificationMeta(
    'increaseFlagged',
  );
  @override
  late final GeneratedColumn<bool> increaseFlagged = GeneratedColumn<bool>(
    'increase_flagged',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("increase_flagged" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supersetGroupMeta = const VerificationMeta(
    'supersetGroup',
  );
  @override
  late final GeneratedColumn<int> supersetGroup = GeneratedColumn<int>(
    'superset_group',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    synced,
    deleted,
    id,
    sessionId,
    exerciseId,
    orderIndex,
    targetSets,
    repRangeMin,
    repRangeMax,
    suggestedWeightKg,
    increaseFlagged,
    notes,
    supersetGroup,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'session_exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<SessionExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('order_index')) {
      context.handle(
        _orderIndexMeta,
        orderIndex.isAcceptableOrUnknown(data['order_index']!, _orderIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_orderIndexMeta);
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    } else if (isInserting) {
      context.missing(_targetSetsMeta);
    }
    if (data.containsKey('rep_range_min')) {
      context.handle(
        _repRangeMinMeta,
        repRangeMin.isAcceptableOrUnknown(
          data['rep_range_min']!,
          _repRangeMinMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repRangeMinMeta);
    }
    if (data.containsKey('rep_range_max')) {
      context.handle(
        _repRangeMaxMeta,
        repRangeMax.isAcceptableOrUnknown(
          data['rep_range_max']!,
          _repRangeMaxMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_repRangeMaxMeta);
    }
    if (data.containsKey('suggested_weight_kg')) {
      context.handle(
        _suggestedWeightKgMeta,
        suggestedWeightKg.isAcceptableOrUnknown(
          data['suggested_weight_kg']!,
          _suggestedWeightKgMeta,
        ),
      );
    }
    if (data.containsKey('increase_flagged')) {
      context.handle(
        _increaseFlaggedMeta,
        increaseFlagged.isAcceptableOrUnknown(
          data['increase_flagged']!,
          _increaseFlaggedMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('superset_group')) {
      context.handle(
        _supersetGroupMeta,
        supersetGroup.isAcceptableOrUnknown(
          data['superset_group']!,
          _supersetGroupMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SessionExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SessionExerciseRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      orderIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}order_index'],
      )!,
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      )!,
      repRangeMin: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_range_min'],
      )!,
      repRangeMax: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_range_max'],
      )!,
      suggestedWeightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}suggested_weight_kg'],
      ),
      increaseFlagged: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}increase_flagged'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      supersetGroup: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}superset_group'],
      ),
    );
  }

  @override
  $SessionExercisesTable createAlias(String alias) {
    return $SessionExercisesTable(attachedDatabase, alias);
  }
}

class SessionExerciseRow extends DataClass
    implements Insertable<SessionExerciseRow> {
  final DateTime updatedAt;
  final bool synced;

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  final bool deleted;
  final String id;
  final String sessionId;
  final String exerciseId;
  final int orderIndex;
  final int targetSets;
  final int repRangeMin;
  final int repRangeMax;

  /// Weight the progression engine suggested when the session was built, and
  /// whether that suggestion was an increase. Frozen here so past sessions keep
  /// showing what the app actually told you at the time.
  final double? suggestedWeightKg;
  final bool increaseFlagged;
  final String? notes;

  /// Frozen copy of the template's superset grouping, so a past session keeps
  /// showing how it was actually run.
  final int? supersetGroup;
  const SessionExerciseRow({
    required this.updatedAt,
    required this.synced,
    required this.deleted,
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.orderIndex,
    required this.targetSets,
    required this.repRangeMin,
    required this.repRangeMax,
    this.suggestedWeightKg,
    required this.increaseFlagged,
    this.notes,
    this.supersetGroup,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['order_index'] = Variable<int>(orderIndex);
    map['target_sets'] = Variable<int>(targetSets);
    map['rep_range_min'] = Variable<int>(repRangeMin);
    map['rep_range_max'] = Variable<int>(repRangeMax);
    if (!nullToAbsent || suggestedWeightKg != null) {
      map['suggested_weight_kg'] = Variable<double>(suggestedWeightKg);
    }
    map['increase_flagged'] = Variable<bool>(increaseFlagged);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || supersetGroup != null) {
      map['superset_group'] = Variable<int>(supersetGroup);
    }
    return map;
  }

  SessionExercisesCompanion toCompanion(bool nullToAbsent) {
    return SessionExercisesCompanion(
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(orderIndex),
      targetSets: Value(targetSets),
      repRangeMin: Value(repRangeMin),
      repRangeMax: Value(repRangeMax),
      suggestedWeightKg: suggestedWeightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedWeightKg),
      increaseFlagged: Value(increaseFlagged),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      supersetGroup: supersetGroup == null && nullToAbsent
          ? const Value.absent()
          : Value(supersetGroup),
    );
  }

  factory SessionExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SessionExerciseRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      orderIndex: serializer.fromJson<int>(json['orderIndex']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      repRangeMin: serializer.fromJson<int>(json['repRangeMin']),
      repRangeMax: serializer.fromJson<int>(json['repRangeMax']),
      suggestedWeightKg: serializer.fromJson<double?>(
        json['suggestedWeightKg'],
      ),
      increaseFlagged: serializer.fromJson<bool>(json['increaseFlagged']),
      notes: serializer.fromJson<String?>(json['notes']),
      supersetGroup: serializer.fromJson<int?>(json['supersetGroup']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'orderIndex': serializer.toJson<int>(orderIndex),
      'targetSets': serializer.toJson<int>(targetSets),
      'repRangeMin': serializer.toJson<int>(repRangeMin),
      'repRangeMax': serializer.toJson<int>(repRangeMax),
      'suggestedWeightKg': serializer.toJson<double?>(suggestedWeightKg),
      'increaseFlagged': serializer.toJson<bool>(increaseFlagged),
      'notes': serializer.toJson<String?>(notes),
      'supersetGroup': serializer.toJson<int?>(supersetGroup),
    };
  }

  SessionExerciseRow copyWith({
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
    String? id,
    String? sessionId,
    String? exerciseId,
    int? orderIndex,
    int? targetSets,
    int? repRangeMin,
    int? repRangeMax,
    Value<double?> suggestedWeightKg = const Value.absent(),
    bool? increaseFlagged,
    Value<String?> notes = const Value.absent(),
    Value<int?> supersetGroup = const Value.absent(),
  }) => SessionExerciseRow(
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    orderIndex: orderIndex ?? this.orderIndex,
    targetSets: targetSets ?? this.targetSets,
    repRangeMin: repRangeMin ?? this.repRangeMin,
    repRangeMax: repRangeMax ?? this.repRangeMax,
    suggestedWeightKg: suggestedWeightKg.present
        ? suggestedWeightKg.value
        : this.suggestedWeightKg,
    increaseFlagged: increaseFlagged ?? this.increaseFlagged,
    notes: notes.present ? notes.value : this.notes,
    supersetGroup: supersetGroup.present
        ? supersetGroup.value
        : this.supersetGroup,
  );
  SessionExerciseRow copyWithCompanion(SessionExercisesCompanion data) {
    return SessionExerciseRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      orderIndex: data.orderIndex.present
          ? data.orderIndex.value
          : this.orderIndex,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      repRangeMin: data.repRangeMin.present
          ? data.repRangeMin.value
          : this.repRangeMin,
      repRangeMax: data.repRangeMax.present
          ? data.repRangeMax.value
          : this.repRangeMax,
      suggestedWeightKg: data.suggestedWeightKg.present
          ? data.suggestedWeightKg.value
          : this.suggestedWeightKg,
      increaseFlagged: data.increaseFlagged.present
          ? data.increaseFlagged.value
          : this.increaseFlagged,
      notes: data.notes.present ? data.notes.value : this.notes,
      supersetGroup: data.supersetGroup.present
          ? data.supersetGroup.value
          : this.supersetGroup,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SessionExerciseRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('targetSets: $targetSets, ')
          ..write('repRangeMin: $repRangeMin, ')
          ..write('repRangeMax: $repRangeMax, ')
          ..write('suggestedWeightKg: $suggestedWeightKg, ')
          ..write('increaseFlagged: $increaseFlagged, ')
          ..write('notes: $notes, ')
          ..write('supersetGroup: $supersetGroup')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    synced,
    deleted,
    id,
    sessionId,
    exerciseId,
    orderIndex,
    targetSets,
    repRangeMin,
    repRangeMax,
    suggestedWeightKg,
    increaseFlagged,
    notes,
    supersetGroup,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionExerciseRow &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.orderIndex == this.orderIndex &&
          other.targetSets == this.targetSets &&
          other.repRangeMin == this.repRangeMin &&
          other.repRangeMax == this.repRangeMax &&
          other.suggestedWeightKg == this.suggestedWeightKg &&
          other.increaseFlagged == this.increaseFlagged &&
          other.notes == this.notes &&
          other.supersetGroup == this.supersetGroup);
}

class SessionExercisesCompanion extends UpdateCompanion<SessionExerciseRow> {
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> exerciseId;
  final Value<int> orderIndex;
  final Value<int> targetSets;
  final Value<int> repRangeMin;
  final Value<int> repRangeMax;
  final Value<double?> suggestedWeightKg;
  final Value<bool> increaseFlagged;
  final Value<String?> notes;
  final Value<int?> supersetGroup;
  final Value<int> rowid;
  const SessionExercisesCompanion({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.orderIndex = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.repRangeMin = const Value.absent(),
    this.repRangeMax = const Value.absent(),
    this.suggestedWeightKg = const Value.absent(),
    this.increaseFlagged = const Value.absent(),
    this.notes = const Value.absent(),
    this.supersetGroup = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SessionExercisesCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    required String id,
    required String sessionId,
    required String exerciseId,
    required int orderIndex,
    required int targetSets,
    required int repRangeMin,
    required int repRangeMax,
    this.suggestedWeightKg = const Value.absent(),
    this.increaseFlagged = const Value.absent(),
    this.notes = const Value.absent(),
    this.supersetGroup = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       orderIndex = Value(orderIndex),
       targetSets = Value(targetSets),
       repRangeMin = Value(repRangeMin),
       repRangeMax = Value(repRangeMax);
  static Insertable<SessionExerciseRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<int>? orderIndex,
    Expression<int>? targetSets,
    Expression<int>? repRangeMin,
    Expression<int>? repRangeMax,
    Expression<double>? suggestedWeightKg,
    Expression<bool>? increaseFlagged,
    Expression<String>? notes,
    Expression<int>? supersetGroup,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (orderIndex != null) 'order_index': orderIndex,
      if (targetSets != null) 'target_sets': targetSets,
      if (repRangeMin != null) 'rep_range_min': repRangeMin,
      if (repRangeMax != null) 'rep_range_max': repRangeMax,
      if (suggestedWeightKg != null) 'suggested_weight_kg': suggestedWeightKg,
      if (increaseFlagged != null) 'increase_flagged': increaseFlagged,
      if (notes != null) 'notes': notes,
      if (supersetGroup != null) 'superset_group': supersetGroup,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SessionExercisesCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? exerciseId,
    Value<int>? orderIndex,
    Value<int>? targetSets,
    Value<int>? repRangeMin,
    Value<int>? repRangeMax,
    Value<double?>? suggestedWeightKg,
    Value<bool>? increaseFlagged,
    Value<String?>? notes,
    Value<int?>? supersetGroup,
    Value<int>? rowid,
  }) {
    return SessionExercisesCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      orderIndex: orderIndex ?? this.orderIndex,
      targetSets: targetSets ?? this.targetSets,
      repRangeMin: repRangeMin ?? this.repRangeMin,
      repRangeMax: repRangeMax ?? this.repRangeMax,
      suggestedWeightKg: suggestedWeightKg ?? this.suggestedWeightKg,
      increaseFlagged: increaseFlagged ?? this.increaseFlagged,
      notes: notes ?? this.notes,
      supersetGroup: supersetGroup ?? this.supersetGroup,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (orderIndex.present) {
      map['order_index'] = Variable<int>(orderIndex.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (repRangeMin.present) {
      map['rep_range_min'] = Variable<int>(repRangeMin.value);
    }
    if (repRangeMax.present) {
      map['rep_range_max'] = Variable<int>(repRangeMax.value);
    }
    if (suggestedWeightKg.present) {
      map['suggested_weight_kg'] = Variable<double>(suggestedWeightKg.value);
    }
    if (increaseFlagged.present) {
      map['increase_flagged'] = Variable<bool>(increaseFlagged.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (supersetGroup.present) {
      map['superset_group'] = Variable<int>(supersetGroup.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SessionExercisesCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('orderIndex: $orderIndex, ')
          ..write('targetSets: $targetSets, ')
          ..write('repRangeMin: $repRangeMin, ')
          ..write('repRangeMax: $repRangeMax, ')
          ..write('suggestedWeightKg: $suggestedWeightKg, ')
          ..write('increaseFlagged: $increaseFlagged, ')
          ..write('notes: $notes, ')
          ..write('supersetGroup: $supersetGroup, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSetsTable extends WorkoutSets
    with TableInfo<$WorkoutSetsTable, WorkoutSetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES sessions (id)',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _setNoMeta = const VerificationMeta('setNo');
  @override
  late final GeneratedColumn<int> setNo = GeneratedColumn<int>(
    'set_no',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<int> rpe = GeneratedColumn<int>(
    'rpe',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isPrMeta = const VerificationMeta('isPr');
  @override
  late final GeneratedColumn<bool> isPr = GeneratedColumn<bool>(
    'is_pr',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_pr" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isWarmupMeta = const VerificationMeta(
    'isWarmup',
  );
  @override
  late final GeneratedColumn<bool> isWarmup = GeneratedColumn<bool>(
    'is_warmup',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_warmup" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    synced,
    deleted,
    id,
    sessionId,
    exerciseId,
    setNo,
    weightKg,
    reps,
    rpe,
    note,
    isPr,
    isWarmup,
    completedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sets';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSetRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('set_no')) {
      context.handle(
        _setNoMeta,
        setNo.isAcceptableOrUnknown(data['set_no']!, _setNoMeta),
      );
    } else if (isInserting) {
      context.missing(_setNoMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('is_pr')) {
      context.handle(
        _isPrMeta,
        isPr.isAcceptableOrUnknown(data['is_pr']!, _isPrMeta),
      );
    }
    if (data.containsKey('is_warmup')) {
      context.handle(
        _isWarmupMeta,
        isWarmup.isAcceptableOrUnknown(data['is_warmup']!, _isWarmupMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSetRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      setNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}set_no'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rpe'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      isPr: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_pr'],
      )!,
      isWarmup: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_warmup'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $WorkoutSetsTable createAlias(String alias) {
    return $WorkoutSetsTable(attachedDatabase, alias);
  }
}

class WorkoutSetRow extends DataClass implements Insertable<WorkoutSetRow> {
  final DateTime updatedAt;
  final bool synced;

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  final bool deleted;
  final String id;
  final String sessionId;
  final String exerciseId;
  final int setNo;
  final double weightKg;
  final int reps;
  final int? rpe;
  final String? note;
  final bool isPr;
  final bool isWarmup;
  final DateTime completedAt;
  const WorkoutSetRow({
    required this.updatedAt,
    required this.synced,
    required this.deleted,
    required this.id,
    required this.sessionId,
    required this.exerciseId,
    required this.setNo,
    required this.weightKg,
    required this.reps,
    this.rpe,
    this.note,
    required this.isPr,
    required this.isWarmup,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['session_id'] = Variable<String>(sessionId);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['set_no'] = Variable<int>(setNo);
    map['weight_kg'] = Variable<double>(weightKg);
    map['reps'] = Variable<int>(reps);
    if (!nullToAbsent || rpe != null) {
      map['rpe'] = Variable<int>(rpe);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['is_pr'] = Variable<bool>(isPr);
    map['is_warmup'] = Variable<bool>(isWarmup);
    map['completed_at'] = Variable<DateTime>(completedAt);
    return map;
  }

  WorkoutSetsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSetsCompanion(
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      setNo: Value(setNo),
      weightKg: Value(weightKg),
      reps: Value(reps),
      rpe: rpe == null && nullToAbsent ? const Value.absent() : Value(rpe),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      isPr: Value(isPr),
      isWarmup: Value(isWarmup),
      completedAt: Value(completedAt),
    );
  }

  factory WorkoutSetRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSetRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      sessionId: serializer.fromJson<String>(json['sessionId']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      setNo: serializer.fromJson<int>(json['setNo']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      reps: serializer.fromJson<int>(json['reps']),
      rpe: serializer.fromJson<int?>(json['rpe']),
      note: serializer.fromJson<String?>(json['note']),
      isPr: serializer.fromJson<bool>(json['isPr']),
      isWarmup: serializer.fromJson<bool>(json['isWarmup']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'sessionId': serializer.toJson<String>(sessionId),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'setNo': serializer.toJson<int>(setNo),
      'weightKg': serializer.toJson<double>(weightKg),
      'reps': serializer.toJson<int>(reps),
      'rpe': serializer.toJson<int?>(rpe),
      'note': serializer.toJson<String?>(note),
      'isPr': serializer.toJson<bool>(isPr),
      'isWarmup': serializer.toJson<bool>(isWarmup),
      'completedAt': serializer.toJson<DateTime>(completedAt),
    };
  }

  WorkoutSetRow copyWith({
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
    String? id,
    String? sessionId,
    String? exerciseId,
    int? setNo,
    double? weightKg,
    int? reps,
    Value<int?> rpe = const Value.absent(),
    Value<String?> note = const Value.absent(),
    bool? isPr,
    bool? isWarmup,
    DateTime? completedAt,
  }) => WorkoutSetRow(
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    exerciseId: exerciseId ?? this.exerciseId,
    setNo: setNo ?? this.setNo,
    weightKg: weightKg ?? this.weightKg,
    reps: reps ?? this.reps,
    rpe: rpe.present ? rpe.value : this.rpe,
    note: note.present ? note.value : this.note,
    isPr: isPr ?? this.isPr,
    isWarmup: isWarmup ?? this.isWarmup,
    completedAt: completedAt ?? this.completedAt,
  );
  WorkoutSetRow copyWithCompanion(WorkoutSetsCompanion data) {
    return WorkoutSetRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      setNo: data.setNo.present ? data.setNo.value : this.setNo,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      note: data.note.present ? data.note.value : this.note,
      isPr: data.isPr.present ? data.isPr.value : this.isPr,
      isWarmup: data.isWarmup.present ? data.isWarmup.value : this.isWarmup,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setNo: $setNo, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('rpe: $rpe, ')
          ..write('note: $note, ')
          ..write('isPr: $isPr, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    synced,
    deleted,
    id,
    sessionId,
    exerciseId,
    setNo,
    weightKg,
    reps,
    rpe,
    note,
    isPr,
    isWarmup,
    completedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSetRow &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.exerciseId == this.exerciseId &&
          other.setNo == this.setNo &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.rpe == this.rpe &&
          other.note == this.note &&
          other.isPr == this.isPr &&
          other.isWarmup == this.isWarmup &&
          other.completedAt == this.completedAt);
}

class WorkoutSetsCompanion extends UpdateCompanion<WorkoutSetRow> {
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> sessionId;
  final Value<String> exerciseId;
  final Value<int> setNo;
  final Value<double> weightKg;
  final Value<int> reps;
  final Value<int?> rpe;
  final Value<String?> note;
  final Value<bool> isPr;
  final Value<bool> isWarmup;
  final Value<DateTime> completedAt;
  final Value<int> rowid;
  const WorkoutSetsCompanion({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.setNo = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.rpe = const Value.absent(),
    this.note = const Value.absent(),
    this.isPr = const Value.absent(),
    this.isWarmup = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WorkoutSetsCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    required String id,
    required String sessionId,
    required String exerciseId,
    required int setNo,
    required double weightKg,
    required int reps,
    this.rpe = const Value.absent(),
    this.note = const Value.absent(),
    this.isPr = const Value.absent(),
    this.isWarmup = const Value.absent(),
    required DateTime completedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       sessionId = Value(sessionId),
       exerciseId = Value(exerciseId),
       setNo = Value(setNo),
       weightKg = Value(weightKg),
       reps = Value(reps),
       completedAt = Value(completedAt);
  static Insertable<WorkoutSetRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? sessionId,
    Expression<String>? exerciseId,
    Expression<int>? setNo,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<int>? rpe,
    Expression<String>? note,
    Expression<bool>? isPr,
    Expression<bool>? isWarmup,
    Expression<DateTime>? completedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (setNo != null) 'set_no': setNo,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (rpe != null) 'rpe': rpe,
      if (note != null) 'note': note,
      if (isPr != null) 'is_pr': isPr,
      if (isWarmup != null) 'is_warmup': isWarmup,
      if (completedAt != null) 'completed_at': completedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WorkoutSetsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? sessionId,
    Value<String>? exerciseId,
    Value<int>? setNo,
    Value<double>? weightKg,
    Value<int>? reps,
    Value<int?>? rpe,
    Value<String?>? note,
    Value<bool>? isPr,
    Value<bool>? isWarmup,
    Value<DateTime>? completedAt,
    Value<int>? rowid,
  }) {
    return WorkoutSetsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      exerciseId: exerciseId ?? this.exerciseId,
      setNo: setNo ?? this.setNo,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      note: note ?? this.note,
      isPr: isPr ?? this.isPr,
      isWarmup: isWarmup ?? this.isWarmup,
      completedAt: completedAt ?? this.completedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (setNo.present) {
      map['set_no'] = Variable<int>(setNo.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<int>(rpe.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (isPr.present) {
      map['is_pr'] = Variable<bool>(isPr.value);
    }
    if (isWarmup.present) {
      map['is_warmup'] = Variable<bool>(isWarmup.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSetsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setNo: $setNo, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('rpe: $rpe, ')
          ..write('note: $note, ')
          ..write('isPr: $isPr, ')
          ..write('isWarmup: $isWarmup, ')
          ..write('completedAt: $completedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PersonalRecordsTable extends PersonalRecords
    with TableInfo<$PersonalRecordsTable, PersonalRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PersonalRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id)',
    ),
  );
  static const VerificationMeta _setIdMeta = const VerificationMeta('setId');
  @override
  late final GeneratedColumn<String> setId = GeneratedColumn<String>(
    'set_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<String> sessionId = GeneratedColumn<String>(
    'session_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PrType, String> type =
      GeneratedColumn<String>(
        'type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PrType>($PersonalRecordsTable.$convertertype);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<double> value = GeneratedColumn<double>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _previousValueMeta = const VerificationMeta(
    'previousValue',
  );
  @override
  late final GeneratedColumn<double> previousValue = GeneratedColumn<double>(
    'previous_value',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _achievedAtMeta = const VerificationMeta(
    'achievedAt',
  );
  @override
  late final GeneratedColumn<DateTime> achievedAt = GeneratedColumn<DateTime>(
    'achieved_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    synced,
    deleted,
    id,
    exerciseId,
    setId,
    sessionId,
    type,
    value,
    weightKg,
    reps,
    previousValue,
    achievedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'personal_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<PersonalRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('set_id')) {
      context.handle(
        _setIdMeta,
        setId.isAcceptableOrUnknown(data['set_id']!, _setIdMeta),
      );
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('previous_value')) {
      context.handle(
        _previousValueMeta,
        previousValue.isAcceptableOrUnknown(
          data['previous_value']!,
          _previousValueMeta,
        ),
      );
    }
    if (data.containsKey('achieved_at')) {
      context.handle(
        _achievedAtMeta,
        achievedAt.isAcceptableOrUnknown(data['achieved_at']!, _achievedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_achievedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PersonalRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PersonalRecordRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      setId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}set_id'],
      ),
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}session_id'],
      ),
      type: $PersonalRecordsTable.$convertertype.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}type'],
        )!,
      ),
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}value'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      previousValue: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}previous_value'],
      ),
      achievedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}achieved_at'],
      )!,
    );
  }

  @override
  $PersonalRecordsTable createAlias(String alias) {
    return $PersonalRecordsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PrType, String, String> $convertertype =
      const EnumNameConverter<PrType>(PrType.values);
}

class PersonalRecordRow extends DataClass
    implements Insertable<PersonalRecordRow> {
  final DateTime updatedAt;
  final bool synced;

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  final bool deleted;
  final String id;
  final String exerciseId;
  final String? setId;
  final String? sessionId;
  final PrType type;

  /// The headline number: kg for weight PRs, reps for rep PRs, estimated kg for
  /// e1RM PRs.
  final double value;
  final double weightKg;
  final int reps;
  final double? previousValue;
  final DateTime achievedAt;
  const PersonalRecordRow({
    required this.updatedAt,
    required this.synced,
    required this.deleted,
    required this.id,
    required this.exerciseId,
    this.setId,
    this.sessionId,
    required this.type,
    required this.value,
    required this.weightKg,
    required this.reps,
    this.previousValue,
    required this.achievedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    if (!nullToAbsent || setId != null) {
      map['set_id'] = Variable<String>(setId);
    }
    if (!nullToAbsent || sessionId != null) {
      map['session_id'] = Variable<String>(sessionId);
    }
    {
      map['type'] = Variable<String>(
        $PersonalRecordsTable.$convertertype.toSql(type),
      );
    }
    map['value'] = Variable<double>(value);
    map['weight_kg'] = Variable<double>(weightKg);
    map['reps'] = Variable<int>(reps);
    if (!nullToAbsent || previousValue != null) {
      map['previous_value'] = Variable<double>(previousValue);
    }
    map['achieved_at'] = Variable<DateTime>(achievedAt);
    return map;
  }

  PersonalRecordsCompanion toCompanion(bool nullToAbsent) {
    return PersonalRecordsCompanion(
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
      id: Value(id),
      exerciseId: Value(exerciseId),
      setId: setId == null && nullToAbsent
          ? const Value.absent()
          : Value(setId),
      sessionId: sessionId == null && nullToAbsent
          ? const Value.absent()
          : Value(sessionId),
      type: Value(type),
      value: Value(value),
      weightKg: Value(weightKg),
      reps: Value(reps),
      previousValue: previousValue == null && nullToAbsent
          ? const Value.absent()
          : Value(previousValue),
      achievedAt: Value(achievedAt),
    );
  }

  factory PersonalRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PersonalRecordRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      setId: serializer.fromJson<String?>(json['setId']),
      sessionId: serializer.fromJson<String?>(json['sessionId']),
      type: $PersonalRecordsTable.$convertertype.fromJson(
        serializer.fromJson<String>(json['type']),
      ),
      value: serializer.fromJson<double>(json['value']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      reps: serializer.fromJson<int>(json['reps']),
      previousValue: serializer.fromJson<double?>(json['previousValue']),
      achievedAt: serializer.fromJson<DateTime>(json['achievedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'setId': serializer.toJson<String?>(setId),
      'sessionId': serializer.toJson<String?>(sessionId),
      'type': serializer.toJson<String>(
        $PersonalRecordsTable.$convertertype.toJson(type),
      ),
      'value': serializer.toJson<double>(value),
      'weightKg': serializer.toJson<double>(weightKg),
      'reps': serializer.toJson<int>(reps),
      'previousValue': serializer.toJson<double?>(previousValue),
      'achievedAt': serializer.toJson<DateTime>(achievedAt),
    };
  }

  PersonalRecordRow copyWith({
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
    String? id,
    String? exerciseId,
    Value<String?> setId = const Value.absent(),
    Value<String?> sessionId = const Value.absent(),
    PrType? type,
    double? value,
    double? weightKg,
    int? reps,
    Value<double?> previousValue = const Value.absent(),
    DateTime? achievedAt,
  }) => PersonalRecordRow(
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    setId: setId.present ? setId.value : this.setId,
    sessionId: sessionId.present ? sessionId.value : this.sessionId,
    type: type ?? this.type,
    value: value ?? this.value,
    weightKg: weightKg ?? this.weightKg,
    reps: reps ?? this.reps,
    previousValue: previousValue.present
        ? previousValue.value
        : this.previousValue,
    achievedAt: achievedAt ?? this.achievedAt,
  );
  PersonalRecordRow copyWithCompanion(PersonalRecordsCompanion data) {
    return PersonalRecordRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      setId: data.setId.present ? data.setId.value : this.setId,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      type: data.type.present ? data.type.value : this.type,
      value: data.value.present ? data.value.value : this.value,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      previousValue: data.previousValue.present
          ? data.previousValue.value
          : this.previousValue,
      achievedAt: data.achievedAt.present
          ? data.achievedAt.value
          : this.achievedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setId: $setId, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('previousValue: $previousValue, ')
          ..write('achievedAt: $achievedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    synced,
    deleted,
    id,
    exerciseId,
    setId,
    sessionId,
    type,
    value,
    weightKg,
    reps,
    previousValue,
    achievedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PersonalRecordRow &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.setId == this.setId &&
          other.sessionId == this.sessionId &&
          other.type == this.type &&
          other.value == this.value &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.previousValue == this.previousValue &&
          other.achievedAt == this.achievedAt);
}

class PersonalRecordsCompanion extends UpdateCompanion<PersonalRecordRow> {
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<String> exerciseId;
  final Value<String?> setId;
  final Value<String?> sessionId;
  final Value<PrType> type;
  final Value<double> value;
  final Value<double> weightKg;
  final Value<int> reps;
  final Value<double?> previousValue;
  final Value<DateTime> achievedAt;
  final Value<int> rowid;
  const PersonalRecordsCompanion({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.setId = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.type = const Value.absent(),
    this.value = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.previousValue = const Value.absent(),
    this.achievedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PersonalRecordsCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    required String id,
    required String exerciseId,
    this.setId = const Value.absent(),
    this.sessionId = const Value.absent(),
    required PrType type,
    required double value,
    required double weightKg,
    required int reps,
    this.previousValue = const Value.absent(),
    required DateTime achievedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       exerciseId = Value(exerciseId),
       type = Value(type),
       value = Value(value),
       weightKg = Value(weightKg),
       reps = Value(reps),
       achievedAt = Value(achievedAt);
  static Insertable<PersonalRecordRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<String>? exerciseId,
    Expression<String>? setId,
    Expression<String>? sessionId,
    Expression<String>? type,
    Expression<double>? value,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<double>? previousValue,
    Expression<DateTime>? achievedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (setId != null) 'set_id': setId,
      if (sessionId != null) 'session_id': sessionId,
      if (type != null) 'type': type,
      if (value != null) 'value': value,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (previousValue != null) 'previous_value': previousValue,
      if (achievedAt != null) 'achieved_at': achievedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PersonalRecordsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<String>? id,
    Value<String>? exerciseId,
    Value<String?>? setId,
    Value<String?>? sessionId,
    Value<PrType>? type,
    Value<double>? value,
    Value<double>? weightKg,
    Value<int>? reps,
    Value<double?>? previousValue,
    Value<DateTime>? achievedAt,
    Value<int>? rowid,
  }) {
    return PersonalRecordsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      setId: setId ?? this.setId,
      sessionId: sessionId ?? this.sessionId,
      type: type ?? this.type,
      value: value ?? this.value,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      previousValue: previousValue ?? this.previousValue,
      achievedAt: achievedAt ?? this.achievedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (setId.present) {
      map['set_id'] = Variable<String>(setId.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<String>(sessionId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(
        $PersonalRecordsTable.$convertertype.toSql(type.value),
      );
    }
    if (value.present) {
      map['value'] = Variable<double>(value.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (previousValue.present) {
      map['previous_value'] = Variable<double>(previousValue.value);
    }
    if (achievedAt.present) {
      map['achieved_at'] = Variable<DateTime>(achievedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PersonalRecordsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('setId: $setId, ')
          ..write('sessionId: $sessionId, ')
          ..write('type: $type, ')
          ..write('value: $value, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('previousValue: $previousValue, ')
          ..write('achievedAt: $achievedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DailyMetricsTable extends DailyMetrics
    with TableInfo<$DailyMetricsTable, DailyMetricRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DailyMetricsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<int> steps = GeneratedColumn<int>(
    'steps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waterMlMeta = const VerificationMeta(
    'waterMl',
  );
  @override
  late final GeneratedColumn<int> waterMl = GeneratedColumn<int>(
    'water_ml',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _kcalMeta = const VerificationMeta('kcal');
  @override
  late final GeneratedColumn<int> kcal = GeneratedColumn<int>(
    'kcal',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proteinGMeta = const VerificationMeta(
    'proteinG',
  );
  @override
  late final GeneratedColumn<int> proteinG = GeneratedColumn<int>(
    'protein_g',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sleepHoursMeta = const VerificationMeta(
    'sleepHours',
  );
  @override
  late final GeneratedColumn<double> sleepHours = GeneratedColumn<double>(
    'sleep_hours',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _chestCmMeta = const VerificationMeta(
    'chestCm',
  );
  @override
  late final GeneratedColumn<double> chestCm = GeneratedColumn<double>(
    'chest_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _waistCmMeta = const VerificationMeta(
    'waistCm',
  );
  @override
  late final GeneratedColumn<double> waistCm = GeneratedColumn<double>(
    'waist_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _hipsCmMeta = const VerificationMeta('hipsCm');
  @override
  late final GeneratedColumn<double> hipsCm = GeneratedColumn<double>(
    'hips_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _armCmMeta = const VerificationMeta('armCm');
  @override
  late final GeneratedColumn<double> armCm = GeneratedColumn<double>(
    'arm_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _thighCmMeta = const VerificationMeta(
    'thighCm',
  );
  @override
  late final GeneratedColumn<double> thighCm = GeneratedColumn<double>(
    'thigh_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _neckCmMeta = const VerificationMeta('neckCm');
  @override
  late final GeneratedColumn<double> neckCm = GeneratedColumn<double>(
    'neck_cm',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _stepsFromHealthMeta = const VerificationMeta(
    'stepsFromHealth',
  );
  @override
  late final GeneratedColumn<bool> stepsFromHealth = GeneratedColumn<bool>(
    'steps_from_health',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("steps_from_health" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _sleepFromHealthMeta = const VerificationMeta(
    'sleepFromHealth',
  );
  @override
  late final GeneratedColumn<bool> sleepFromHealth = GeneratedColumn<bool>(
    'sleep_from_health',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("sleep_from_health" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _weightFromHealthMeta = const VerificationMeta(
    'weightFromHealth',
  );
  @override
  late final GeneratedColumn<bool> weightFromHealth = GeneratedColumn<bool>(
    'weight_from_health',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("weight_from_health" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    synced,
    deleted,
    date,
    weightKg,
    steps,
    waterMl,
    kcal,
    proteinG,
    sleepHours,
    chestCm,
    waistCm,
    hipsCm,
    armCm,
    thighCm,
    neckCm,
    stepsFromHealth,
    sleepFromHealth,
    weightFromHealth,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'daily_metrics';
  @override
  VerificationContext validateIntegrity(
    Insertable<DailyMetricRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    }
    if (data.containsKey('water_ml')) {
      context.handle(
        _waterMlMeta,
        waterMl.isAcceptableOrUnknown(data['water_ml']!, _waterMlMeta),
      );
    }
    if (data.containsKey('kcal')) {
      context.handle(
        _kcalMeta,
        kcal.isAcceptableOrUnknown(data['kcal']!, _kcalMeta),
      );
    }
    if (data.containsKey('protein_g')) {
      context.handle(
        _proteinGMeta,
        proteinG.isAcceptableOrUnknown(data['protein_g']!, _proteinGMeta),
      );
    }
    if (data.containsKey('sleep_hours')) {
      context.handle(
        _sleepHoursMeta,
        sleepHours.isAcceptableOrUnknown(data['sleep_hours']!, _sleepHoursMeta),
      );
    }
    if (data.containsKey('chest_cm')) {
      context.handle(
        _chestCmMeta,
        chestCm.isAcceptableOrUnknown(data['chest_cm']!, _chestCmMeta),
      );
    }
    if (data.containsKey('waist_cm')) {
      context.handle(
        _waistCmMeta,
        waistCm.isAcceptableOrUnknown(data['waist_cm']!, _waistCmMeta),
      );
    }
    if (data.containsKey('hips_cm')) {
      context.handle(
        _hipsCmMeta,
        hipsCm.isAcceptableOrUnknown(data['hips_cm']!, _hipsCmMeta),
      );
    }
    if (data.containsKey('arm_cm')) {
      context.handle(
        _armCmMeta,
        armCm.isAcceptableOrUnknown(data['arm_cm']!, _armCmMeta),
      );
    }
    if (data.containsKey('thigh_cm')) {
      context.handle(
        _thighCmMeta,
        thighCm.isAcceptableOrUnknown(data['thigh_cm']!, _thighCmMeta),
      );
    }
    if (data.containsKey('neck_cm')) {
      context.handle(
        _neckCmMeta,
        neckCm.isAcceptableOrUnknown(data['neck_cm']!, _neckCmMeta),
      );
    }
    if (data.containsKey('steps_from_health')) {
      context.handle(
        _stepsFromHealthMeta,
        stepsFromHealth.isAcceptableOrUnknown(
          data['steps_from_health']!,
          _stepsFromHealthMeta,
        ),
      );
    }
    if (data.containsKey('sleep_from_health')) {
      context.handle(
        _sleepFromHealthMeta,
        sleepFromHealth.isAcceptableOrUnknown(
          data['sleep_from_health']!,
          _sleepFromHealthMeta,
        ),
      );
    }
    if (data.containsKey('weight_from_health')) {
      context.handle(
        _weightFromHealthMeta,
        weightFromHealth.isAcceptableOrUnknown(
          data['weight_from_health']!,
          _weightFromHealthMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  DailyMetricRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DailyMetricRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      ),
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}steps'],
      ),
      waterMl: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}water_ml'],
      )!,
      kcal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}kcal'],
      ),
      proteinG: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}protein_g'],
      ),
      sleepHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sleep_hours'],
      ),
      chestCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}chest_cm'],
      ),
      waistCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}waist_cm'],
      ),
      hipsCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}hips_cm'],
      ),
      armCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}arm_cm'],
      ),
      thighCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}thigh_cm'],
      ),
      neckCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}neck_cm'],
      ),
      stepsFromHealth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}steps_from_health'],
      )!,
      sleepFromHealth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}sleep_from_health'],
      )!,
      weightFromHealth: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}weight_from_health'],
      )!,
    );
  }

  @override
  $DailyMetricsTable createAlias(String alias) {
    return $DailyMetricsTable(attachedDatabase, alias);
  }
}

class DailyMetricRow extends DataClass implements Insertable<DailyMetricRow> {
  final DateTime updatedAt;
  final bool synced;

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  final bool deleted;

  /// Midnight-normalised local day. One row per day.
  final DateTime date;
  final double? weightKg;
  final int? steps;
  final int waterMl;
  final int? kcal;
  final int? proteinG;
  final double? sleepHours;

  /// Tape measurements, in centimetres. Logged as often as the user cares to
  /// — usually weekly — and charted alongside body weight, which is the
  /// number that actually tells you whether a bulk is going where you want.
  final double? chestCm;
  final double? waistCm;
  final double? hipsCm;
  final double? armCm;
  final double? thighCm;
  final double? neckCm;

  /// Steps/sleep can come from Health or be typed in; remember which so a
  /// Health refresh never stomps a manual entry.
  final bool stepsFromHealth;
  final bool sleepFromHealth;
  final bool weightFromHealth;
  const DailyMetricRow({
    required this.updatedAt,
    required this.synced,
    required this.deleted,
    required this.date,
    this.weightKg,
    this.steps,
    required this.waterMl,
    this.kcal,
    this.proteinG,
    this.sleepHours,
    this.chestCm,
    this.waistCm,
    this.hipsCm,
    this.armCm,
    this.thighCm,
    this.neckCm,
    required this.stepsFromHealth,
    required this.sleepFromHealth,
    required this.weightFromHealth,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || steps != null) {
      map['steps'] = Variable<int>(steps);
    }
    map['water_ml'] = Variable<int>(waterMl);
    if (!nullToAbsent || kcal != null) {
      map['kcal'] = Variable<int>(kcal);
    }
    if (!nullToAbsent || proteinG != null) {
      map['protein_g'] = Variable<int>(proteinG);
    }
    if (!nullToAbsent || sleepHours != null) {
      map['sleep_hours'] = Variable<double>(sleepHours);
    }
    if (!nullToAbsent || chestCm != null) {
      map['chest_cm'] = Variable<double>(chestCm);
    }
    if (!nullToAbsent || waistCm != null) {
      map['waist_cm'] = Variable<double>(waistCm);
    }
    if (!nullToAbsent || hipsCm != null) {
      map['hips_cm'] = Variable<double>(hipsCm);
    }
    if (!nullToAbsent || armCm != null) {
      map['arm_cm'] = Variable<double>(armCm);
    }
    if (!nullToAbsent || thighCm != null) {
      map['thigh_cm'] = Variable<double>(thighCm);
    }
    if (!nullToAbsent || neckCm != null) {
      map['neck_cm'] = Variable<double>(neckCm);
    }
    map['steps_from_health'] = Variable<bool>(stepsFromHealth);
    map['sleep_from_health'] = Variable<bool>(sleepFromHealth);
    map['weight_from_health'] = Variable<bool>(weightFromHealth);
    return map;
  }

  DailyMetricsCompanion toCompanion(bool nullToAbsent) {
    return DailyMetricsCompanion(
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
      date: Value(date),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      steps: steps == null && nullToAbsent
          ? const Value.absent()
          : Value(steps),
      waterMl: Value(waterMl),
      kcal: kcal == null && nullToAbsent ? const Value.absent() : Value(kcal),
      proteinG: proteinG == null && nullToAbsent
          ? const Value.absent()
          : Value(proteinG),
      sleepHours: sleepHours == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepHours),
      chestCm: chestCm == null && nullToAbsent
          ? const Value.absent()
          : Value(chestCm),
      waistCm: waistCm == null && nullToAbsent
          ? const Value.absent()
          : Value(waistCm),
      hipsCm: hipsCm == null && nullToAbsent
          ? const Value.absent()
          : Value(hipsCm),
      armCm: armCm == null && nullToAbsent
          ? const Value.absent()
          : Value(armCm),
      thighCm: thighCm == null && nullToAbsent
          ? const Value.absent()
          : Value(thighCm),
      neckCm: neckCm == null && nullToAbsent
          ? const Value.absent()
          : Value(neckCm),
      stepsFromHealth: Value(stepsFromHealth),
      sleepFromHealth: Value(sleepFromHealth),
      weightFromHealth: Value(weightFromHealth),
    );
  }

  factory DailyMetricRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DailyMetricRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      steps: serializer.fromJson<int?>(json['steps']),
      waterMl: serializer.fromJson<int>(json['waterMl']),
      kcal: serializer.fromJson<int?>(json['kcal']),
      proteinG: serializer.fromJson<int?>(json['proteinG']),
      sleepHours: serializer.fromJson<double?>(json['sleepHours']),
      chestCm: serializer.fromJson<double?>(json['chestCm']),
      waistCm: serializer.fromJson<double?>(json['waistCm']),
      hipsCm: serializer.fromJson<double?>(json['hipsCm']),
      armCm: serializer.fromJson<double?>(json['armCm']),
      thighCm: serializer.fromJson<double?>(json['thighCm']),
      neckCm: serializer.fromJson<double?>(json['neckCm']),
      stepsFromHealth: serializer.fromJson<bool>(json['stepsFromHealth']),
      sleepFromHealth: serializer.fromJson<bool>(json['sleepFromHealth']),
      weightFromHealth: serializer.fromJson<bool>(json['weightFromHealth']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double?>(weightKg),
      'steps': serializer.toJson<int?>(steps),
      'waterMl': serializer.toJson<int>(waterMl),
      'kcal': serializer.toJson<int?>(kcal),
      'proteinG': serializer.toJson<int?>(proteinG),
      'sleepHours': serializer.toJson<double?>(sleepHours),
      'chestCm': serializer.toJson<double?>(chestCm),
      'waistCm': serializer.toJson<double?>(waistCm),
      'hipsCm': serializer.toJson<double?>(hipsCm),
      'armCm': serializer.toJson<double?>(armCm),
      'thighCm': serializer.toJson<double?>(thighCm),
      'neckCm': serializer.toJson<double?>(neckCm),
      'stepsFromHealth': serializer.toJson<bool>(stepsFromHealth),
      'sleepFromHealth': serializer.toJson<bool>(sleepFromHealth),
      'weightFromHealth': serializer.toJson<bool>(weightFromHealth),
    };
  }

  DailyMetricRow copyWith({
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
    DateTime? date,
    Value<double?> weightKg = const Value.absent(),
    Value<int?> steps = const Value.absent(),
    int? waterMl,
    Value<int?> kcal = const Value.absent(),
    Value<int?> proteinG = const Value.absent(),
    Value<double?> sleepHours = const Value.absent(),
    Value<double?> chestCm = const Value.absent(),
    Value<double?> waistCm = const Value.absent(),
    Value<double?> hipsCm = const Value.absent(),
    Value<double?> armCm = const Value.absent(),
    Value<double?> thighCm = const Value.absent(),
    Value<double?> neckCm = const Value.absent(),
    bool? stepsFromHealth,
    bool? sleepFromHealth,
    bool? weightFromHealth,
  }) => DailyMetricRow(
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
    date: date ?? this.date,
    weightKg: weightKg.present ? weightKg.value : this.weightKg,
    steps: steps.present ? steps.value : this.steps,
    waterMl: waterMl ?? this.waterMl,
    kcal: kcal.present ? kcal.value : this.kcal,
    proteinG: proteinG.present ? proteinG.value : this.proteinG,
    sleepHours: sleepHours.present ? sleepHours.value : this.sleepHours,
    chestCm: chestCm.present ? chestCm.value : this.chestCm,
    waistCm: waistCm.present ? waistCm.value : this.waistCm,
    hipsCm: hipsCm.present ? hipsCm.value : this.hipsCm,
    armCm: armCm.present ? armCm.value : this.armCm,
    thighCm: thighCm.present ? thighCm.value : this.thighCm,
    neckCm: neckCm.present ? neckCm.value : this.neckCm,
    stepsFromHealth: stepsFromHealth ?? this.stepsFromHealth,
    sleepFromHealth: sleepFromHealth ?? this.sleepFromHealth,
    weightFromHealth: weightFromHealth ?? this.weightFromHealth,
  );
  DailyMetricRow copyWithCompanion(DailyMetricsCompanion data) {
    return DailyMetricRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      steps: data.steps.present ? data.steps.value : this.steps,
      waterMl: data.waterMl.present ? data.waterMl.value : this.waterMl,
      kcal: data.kcal.present ? data.kcal.value : this.kcal,
      proteinG: data.proteinG.present ? data.proteinG.value : this.proteinG,
      sleepHours: data.sleepHours.present
          ? data.sleepHours.value
          : this.sleepHours,
      chestCm: data.chestCm.present ? data.chestCm.value : this.chestCm,
      waistCm: data.waistCm.present ? data.waistCm.value : this.waistCm,
      hipsCm: data.hipsCm.present ? data.hipsCm.value : this.hipsCm,
      armCm: data.armCm.present ? data.armCm.value : this.armCm,
      thighCm: data.thighCm.present ? data.thighCm.value : this.thighCm,
      neckCm: data.neckCm.present ? data.neckCm.value : this.neckCm,
      stepsFromHealth: data.stepsFromHealth.present
          ? data.stepsFromHealth.value
          : this.stepsFromHealth,
      sleepFromHealth: data.sleepFromHealth.present
          ? data.sleepFromHealth.value
          : this.sleepFromHealth,
      weightFromHealth: data.weightFromHealth.present
          ? data.weightFromHealth.value
          : this.weightFromHealth,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DailyMetricRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('steps: $steps, ')
          ..write('waterMl: $waterMl, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('chestCm: $chestCm, ')
          ..write('waistCm: $waistCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('armCm: $armCm, ')
          ..write('thighCm: $thighCm, ')
          ..write('neckCm: $neckCm, ')
          ..write('stepsFromHealth: $stepsFromHealth, ')
          ..write('sleepFromHealth: $sleepFromHealth, ')
          ..write('weightFromHealth: $weightFromHealth')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    synced,
    deleted,
    date,
    weightKg,
    steps,
    waterMl,
    kcal,
    proteinG,
    sleepHours,
    chestCm,
    waistCm,
    hipsCm,
    armCm,
    thighCm,
    neckCm,
    stepsFromHealth,
    sleepFromHealth,
    weightFromHealth,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DailyMetricRow &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.steps == this.steps &&
          other.waterMl == this.waterMl &&
          other.kcal == this.kcal &&
          other.proteinG == this.proteinG &&
          other.sleepHours == this.sleepHours &&
          other.chestCm == this.chestCm &&
          other.waistCm == this.waistCm &&
          other.hipsCm == this.hipsCm &&
          other.armCm == this.armCm &&
          other.thighCm == this.thighCm &&
          other.neckCm == this.neckCm &&
          other.stepsFromHealth == this.stepsFromHealth &&
          other.sleepFromHealth == this.sleepFromHealth &&
          other.weightFromHealth == this.weightFromHealth);
}

class DailyMetricsCompanion extends UpdateCompanion<DailyMetricRow> {
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<DateTime> date;
  final Value<double?> weightKg;
  final Value<int?> steps;
  final Value<int> waterMl;
  final Value<int?> kcal;
  final Value<int?> proteinG;
  final Value<double?> sleepHours;
  final Value<double?> chestCm;
  final Value<double?> waistCm;
  final Value<double?> hipsCm;
  final Value<double?> armCm;
  final Value<double?> thighCm;
  final Value<double?> neckCm;
  final Value<bool> stepsFromHealth;
  final Value<bool> sleepFromHealth;
  final Value<bool> weightFromHealth;
  final Value<int> rowid;
  const DailyMetricsCompanion({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.steps = const Value.absent(),
    this.waterMl = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.armCm = const Value.absent(),
    this.thighCm = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.stepsFromHealth = const Value.absent(),
    this.sleepFromHealth = const Value.absent(),
    this.weightFromHealth = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DailyMetricsCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    required DateTime date,
    this.weightKg = const Value.absent(),
    this.steps = const Value.absent(),
    this.waterMl = const Value.absent(),
    this.kcal = const Value.absent(),
    this.proteinG = const Value.absent(),
    this.sleepHours = const Value.absent(),
    this.chestCm = const Value.absent(),
    this.waistCm = const Value.absent(),
    this.hipsCm = const Value.absent(),
    this.armCm = const Value.absent(),
    this.thighCm = const Value.absent(),
    this.neckCm = const Value.absent(),
    this.stepsFromHealth = const Value.absent(),
    this.sleepFromHealth = const Value.absent(),
    this.weightFromHealth = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : date = Value(date);
  static Insertable<DailyMetricRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<DateTime>? date,
    Expression<double>? weightKg,
    Expression<int>? steps,
    Expression<int>? waterMl,
    Expression<int>? kcal,
    Expression<int>? proteinG,
    Expression<double>? sleepHours,
    Expression<double>? chestCm,
    Expression<double>? waistCm,
    Expression<double>? hipsCm,
    Expression<double>? armCm,
    Expression<double>? thighCm,
    Expression<double>? neckCm,
    Expression<bool>? stepsFromHealth,
    Expression<bool>? sleepFromHealth,
    Expression<bool>? weightFromHealth,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (steps != null) 'steps': steps,
      if (waterMl != null) 'water_ml': waterMl,
      if (kcal != null) 'kcal': kcal,
      if (proteinG != null) 'protein_g': proteinG,
      if (sleepHours != null) 'sleep_hours': sleepHours,
      if (chestCm != null) 'chest_cm': chestCm,
      if (waistCm != null) 'waist_cm': waistCm,
      if (hipsCm != null) 'hips_cm': hipsCm,
      if (armCm != null) 'arm_cm': armCm,
      if (thighCm != null) 'thigh_cm': thighCm,
      if (neckCm != null) 'neck_cm': neckCm,
      if (stepsFromHealth != null) 'steps_from_health': stepsFromHealth,
      if (sleepFromHealth != null) 'sleep_from_health': sleepFromHealth,
      if (weightFromHealth != null) 'weight_from_health': weightFromHealth,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DailyMetricsCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<DateTime>? date,
    Value<double?>? weightKg,
    Value<int?>? steps,
    Value<int>? waterMl,
    Value<int?>? kcal,
    Value<int?>? proteinG,
    Value<double?>? sleepHours,
    Value<double?>? chestCm,
    Value<double?>? waistCm,
    Value<double?>? hipsCm,
    Value<double?>? armCm,
    Value<double?>? thighCm,
    Value<double?>? neckCm,
    Value<bool>? stepsFromHealth,
    Value<bool>? sleepFromHealth,
    Value<bool>? weightFromHealth,
    Value<int>? rowid,
  }) {
    return DailyMetricsCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      steps: steps ?? this.steps,
      waterMl: waterMl ?? this.waterMl,
      kcal: kcal ?? this.kcal,
      proteinG: proteinG ?? this.proteinG,
      sleepHours: sleepHours ?? this.sleepHours,
      chestCm: chestCm ?? this.chestCm,
      waistCm: waistCm ?? this.waistCm,
      hipsCm: hipsCm ?? this.hipsCm,
      armCm: armCm ?? this.armCm,
      thighCm: thighCm ?? this.thighCm,
      neckCm: neckCm ?? this.neckCm,
      stepsFromHealth: stepsFromHealth ?? this.stepsFromHealth,
      sleepFromHealth: sleepFromHealth ?? this.sleepFromHealth,
      weightFromHealth: weightFromHealth ?? this.weightFromHealth,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (steps.present) {
      map['steps'] = Variable<int>(steps.value);
    }
    if (waterMl.present) {
      map['water_ml'] = Variable<int>(waterMl.value);
    }
    if (kcal.present) {
      map['kcal'] = Variable<int>(kcal.value);
    }
    if (proteinG.present) {
      map['protein_g'] = Variable<int>(proteinG.value);
    }
    if (sleepHours.present) {
      map['sleep_hours'] = Variable<double>(sleepHours.value);
    }
    if (chestCm.present) {
      map['chest_cm'] = Variable<double>(chestCm.value);
    }
    if (waistCm.present) {
      map['waist_cm'] = Variable<double>(waistCm.value);
    }
    if (hipsCm.present) {
      map['hips_cm'] = Variable<double>(hipsCm.value);
    }
    if (armCm.present) {
      map['arm_cm'] = Variable<double>(armCm.value);
    }
    if (thighCm.present) {
      map['thigh_cm'] = Variable<double>(thighCm.value);
    }
    if (neckCm.present) {
      map['neck_cm'] = Variable<double>(neckCm.value);
    }
    if (stepsFromHealth.present) {
      map['steps_from_health'] = Variable<bool>(stepsFromHealth.value);
    }
    if (sleepFromHealth.present) {
      map['sleep_from_health'] = Variable<bool>(sleepFromHealth.value);
    }
    if (weightFromHealth.present) {
      map['weight_from_health'] = Variable<bool>(weightFromHealth.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DailyMetricsCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('steps: $steps, ')
          ..write('waterMl: $waterMl, ')
          ..write('kcal: $kcal, ')
          ..write('proteinG: $proteinG, ')
          ..write('sleepHours: $sleepHours, ')
          ..write('chestCm: $chestCm, ')
          ..write('waistCm: $waistCm, ')
          ..write('hipsCm: $hipsCm, ')
          ..write('armCm: $armCm, ')
          ..write('thighCm: $thighCm, ')
          ..write('neckCm: $neckCm, ')
          ..write('stepsFromHealth: $stepsFromHealth, ')
          ..write('sleepFromHealth: $sleepFromHealth, ')
          ..write('weightFromHealth: $weightFromHealth, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhotosTable extends Photos with TableInfo<$PhotosTable, PhotoRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhotosTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _deletedMeta = const VerificationMeta(
    'deleted',
  );
  @override
  late final GeneratedColumn<bool> deleted = GeneratedColumn<bool>(
    'deleted',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("deleted" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<PhotoPose, String> pose =
      GeneratedColumn<String>(
        'pose',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<PhotoPose>($PhotosTable.$converterpose);
  static const VerificationMeta _localPathMeta = const VerificationMeta(
    'localPath',
  );
  @override
  late final GeneratedColumn<String> localPath = GeneratedColumn<String>(
    'local_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _widthPxMeta = const VerificationMeta(
    'widthPx',
  );
  @override
  late final GeneratedColumn<int> widthPx = GeneratedColumn<int>(
    'width_px',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _heightPxMeta = const VerificationMeta(
    'heightPx',
  );
  @override
  late final GeneratedColumn<int> heightPx = GeneratedColumn<int>(
    'height_px',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _byteSizeMeta = const VerificationMeta(
    'byteSize',
  );
  @override
  late final GeneratedColumn<int> byteSize = GeneratedColumn<int>(
    'byte_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    updatedAt,
    synced,
    deleted,
    id,
    date,
    pose,
    localPath,
    storagePath,
    widthPx,
    heightPx,
    byteSize,
    note,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'photos';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhotoRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    if (data.containsKey('deleted')) {
      context.handle(
        _deletedMeta,
        deleted.isAcceptableOrUnknown(data['deleted']!, _deletedMeta),
      );
    }
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('local_path')) {
      context.handle(
        _localPathMeta,
        localPath.isAcceptableOrUnknown(data['local_path']!, _localPathMeta),
      );
    } else if (isInserting) {
      context.missing(_localPathMeta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    }
    if (data.containsKey('width_px')) {
      context.handle(
        _widthPxMeta,
        widthPx.isAcceptableOrUnknown(data['width_px']!, _widthPxMeta),
      );
    }
    if (data.containsKey('height_px')) {
      context.handle(
        _heightPxMeta,
        heightPx.isAcceptableOrUnknown(data['height_px']!, _heightPxMeta),
      );
    }
    if (data.containsKey('byte_size')) {
      context.handle(
        _byteSizeMeta,
        byteSize.isAcceptableOrUnknown(data['byte_size']!, _byteSizeMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PhotoRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhotoRow(
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
      deleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}deleted'],
      )!,
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      pose: $PhotosTable.$converterpose.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}pose'],
        )!,
      ),
      localPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_path'],
      )!,
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      ),
      widthPx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width_px'],
      ),
      heightPx: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height_px'],
      ),
      byteSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}byte_size'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
    );
  }

  @override
  $PhotosTable createAlias(String alias) {
    return $PhotosTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<PhotoPose, String, String> $converterpose =
      const EnumNameConverter<PhotoPose>(PhotoPose.values);
}

class PhotoRow extends DataClass implements Insertable<PhotoRow> {
  final DateTime updatedAt;
  final bool synced;

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  final bool deleted;
  final String id;
  final DateTime date;
  final PhotoPose pose;

  /// Absolute path inside the app documents directory. Always populated —
  /// photos are local-first and readable with no network.
  final String localPath;
  final String? storagePath;
  final int? widthPx;
  final int? heightPx;
  final int? byteSize;
  final String? note;
  const PhotoRow({
    required this.updatedAt,
    required this.synced,
    required this.deleted,
    required this.id,
    required this.date,
    required this.pose,
    required this.localPath,
    this.storagePath,
    this.widthPx,
    this.heightPx,
    this.byteSize,
    this.note,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['synced'] = Variable<bool>(synced);
    map['deleted'] = Variable<bool>(deleted);
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    {
      map['pose'] = Variable<String>($PhotosTable.$converterpose.toSql(pose));
    }
    map['local_path'] = Variable<String>(localPath);
    if (!nullToAbsent || storagePath != null) {
      map['storage_path'] = Variable<String>(storagePath);
    }
    if (!nullToAbsent || widthPx != null) {
      map['width_px'] = Variable<int>(widthPx);
    }
    if (!nullToAbsent || heightPx != null) {
      map['height_px'] = Variable<int>(heightPx);
    }
    if (!nullToAbsent || byteSize != null) {
      map['byte_size'] = Variable<int>(byteSize);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PhotosCompanion toCompanion(bool nullToAbsent) {
    return PhotosCompanion(
      updatedAt: Value(updatedAt),
      synced: Value(synced),
      deleted: Value(deleted),
      id: Value(id),
      date: Value(date),
      pose: Value(pose),
      localPath: Value(localPath),
      storagePath: storagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePath),
      widthPx: widthPx == null && nullToAbsent
          ? const Value.absent()
          : Value(widthPx),
      heightPx: heightPx == null && nullToAbsent
          ? const Value.absent()
          : Value(heightPx),
      byteSize: byteSize == null && nullToAbsent
          ? const Value.absent()
          : Value(byteSize),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory PhotoRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhotoRow(
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      synced: serializer.fromJson<bool>(json['synced']),
      deleted: serializer.fromJson<bool>(json['deleted']),
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      pose: $PhotosTable.$converterpose.fromJson(
        serializer.fromJson<String>(json['pose']),
      ),
      localPath: serializer.fromJson<String>(json['localPath']),
      storagePath: serializer.fromJson<String?>(json['storagePath']),
      widthPx: serializer.fromJson<int?>(json['widthPx']),
      heightPx: serializer.fromJson<int?>(json['heightPx']),
      byteSize: serializer.fromJson<int?>(json['byteSize']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'synced': serializer.toJson<bool>(synced),
      'deleted': serializer.toJson<bool>(deleted),
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'pose': serializer.toJson<String>(
        $PhotosTable.$converterpose.toJson(pose),
      ),
      'localPath': serializer.toJson<String>(localPath),
      'storagePath': serializer.toJson<String?>(storagePath),
      'widthPx': serializer.toJson<int?>(widthPx),
      'heightPx': serializer.toJson<int?>(heightPx),
      'byteSize': serializer.toJson<int?>(byteSize),
      'note': serializer.toJson<String?>(note),
    };
  }

  PhotoRow copyWith({
    DateTime? updatedAt,
    bool? synced,
    bool? deleted,
    String? id,
    DateTime? date,
    PhotoPose? pose,
    String? localPath,
    Value<String?> storagePath = const Value.absent(),
    Value<int?> widthPx = const Value.absent(),
    Value<int?> heightPx = const Value.absent(),
    Value<int?> byteSize = const Value.absent(),
    Value<String?> note = const Value.absent(),
  }) => PhotoRow(
    updatedAt: updatedAt ?? this.updatedAt,
    synced: synced ?? this.synced,
    deleted: deleted ?? this.deleted,
    id: id ?? this.id,
    date: date ?? this.date,
    pose: pose ?? this.pose,
    localPath: localPath ?? this.localPath,
    storagePath: storagePath.present ? storagePath.value : this.storagePath,
    widthPx: widthPx.present ? widthPx.value : this.widthPx,
    heightPx: heightPx.present ? heightPx.value : this.heightPx,
    byteSize: byteSize.present ? byteSize.value : this.byteSize,
    note: note.present ? note.value : this.note,
  );
  PhotoRow copyWithCompanion(PhotosCompanion data) {
    return PhotoRow(
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      synced: data.synced.present ? data.synced.value : this.synced,
      deleted: data.deleted.present ? data.deleted.value : this.deleted,
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      pose: data.pose.present ? data.pose.value : this.pose,
      localPath: data.localPath.present ? data.localPath.value : this.localPath,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      widthPx: data.widthPx.present ? data.widthPx.value : this.widthPx,
      heightPx: data.heightPx.present ? data.heightPx.value : this.heightPx,
      byteSize: data.byteSize.present ? data.byteSize.value : this.byteSize,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhotoRow(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('pose: $pose, ')
          ..write('localPath: $localPath, ')
          ..write('storagePath: $storagePath, ')
          ..write('widthPx: $widthPx, ')
          ..write('heightPx: $heightPx, ')
          ..write('byteSize: $byteSize, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    updatedAt,
    synced,
    deleted,
    id,
    date,
    pose,
    localPath,
    storagePath,
    widthPx,
    heightPx,
    byteSize,
    note,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhotoRow &&
          other.updatedAt == this.updatedAt &&
          other.synced == this.synced &&
          other.deleted == this.deleted &&
          other.id == this.id &&
          other.date == this.date &&
          other.pose == this.pose &&
          other.localPath == this.localPath &&
          other.storagePath == this.storagePath &&
          other.widthPx == this.widthPx &&
          other.heightPx == this.heightPx &&
          other.byteSize == this.byteSize &&
          other.note == this.note);
}

class PhotosCompanion extends UpdateCompanion<PhotoRow> {
  final Value<DateTime> updatedAt;
  final Value<bool> synced;
  final Value<bool> deleted;
  final Value<String> id;
  final Value<DateTime> date;
  final Value<PhotoPose> pose;
  final Value<String> localPath;
  final Value<String?> storagePath;
  final Value<int?> widthPx;
  final Value<int?> heightPx;
  final Value<int?> byteSize;
  final Value<String?> note;
  final Value<int> rowid;
  const PhotosCompanion({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.pose = const Value.absent(),
    this.localPath = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.widthPx = const Value.absent(),
    this.heightPx = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhotosCompanion.insert({
    this.updatedAt = const Value.absent(),
    this.synced = const Value.absent(),
    this.deleted = const Value.absent(),
    required String id,
    required DateTime date,
    required PhotoPose pose,
    required String localPath,
    this.storagePath = const Value.absent(),
    this.widthPx = const Value.absent(),
    this.heightPx = const Value.absent(),
    this.byteSize = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       date = Value(date),
       pose = Value(pose),
       localPath = Value(localPath);
  static Insertable<PhotoRow> custom({
    Expression<DateTime>? updatedAt,
    Expression<bool>? synced,
    Expression<bool>? deleted,
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? pose,
    Expression<String>? localPath,
    Expression<String>? storagePath,
    Expression<int>? widthPx,
    Expression<int>? heightPx,
    Expression<int>? byteSize,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (updatedAt != null) 'updated_at': updatedAt,
      if (synced != null) 'synced': synced,
      if (deleted != null) 'deleted': deleted,
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (pose != null) 'pose': pose,
      if (localPath != null) 'local_path': localPath,
      if (storagePath != null) 'storage_path': storagePath,
      if (widthPx != null) 'width_px': widthPx,
      if (heightPx != null) 'height_px': heightPx,
      if (byteSize != null) 'byte_size': byteSize,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhotosCompanion copyWith({
    Value<DateTime>? updatedAt,
    Value<bool>? synced,
    Value<bool>? deleted,
    Value<String>? id,
    Value<DateTime>? date,
    Value<PhotoPose>? pose,
    Value<String>? localPath,
    Value<String?>? storagePath,
    Value<int?>? widthPx,
    Value<int?>? heightPx,
    Value<int?>? byteSize,
    Value<String?>? note,
    Value<int>? rowid,
  }) {
    return PhotosCompanion(
      updatedAt: updatedAt ?? this.updatedAt,
      synced: synced ?? this.synced,
      deleted: deleted ?? this.deleted,
      id: id ?? this.id,
      date: date ?? this.date,
      pose: pose ?? this.pose,
      localPath: localPath ?? this.localPath,
      storagePath: storagePath ?? this.storagePath,
      widthPx: widthPx ?? this.widthPx,
      heightPx: heightPx ?? this.heightPx,
      byteSize: byteSize ?? this.byteSize,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (deleted.present) {
      map['deleted'] = Variable<bool>(deleted.value);
    }
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (pose.present) {
      map['pose'] = Variable<String>(
        $PhotosTable.$converterpose.toSql(pose.value),
      );
    }
    if (localPath.present) {
      map['local_path'] = Variable<String>(localPath.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (widthPx.present) {
      map['width_px'] = Variable<int>(widthPx.value);
    }
    if (heightPx.present) {
      map['height_px'] = Variable<int>(heightPx.value);
    }
    if (byteSize.present) {
      map['byte_size'] = Variable<int>(byteSize.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhotosCompanion(')
          ..write('updatedAt: $updatedAt, ')
          ..write('synced: $synced, ')
          ..write('deleted: $deleted, ')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('pose: $pose, ')
          ..write('localPath: $localPath, ')
          ..write('storagePath: $storagePath, ')
          ..write('widthPx: $widthPx, ')
          ..write('heightPx: $heightPx, ')
          ..write('byteSize: $byteSize, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTable extends Settings
    with TableInfo<$SettingsTable, SettingRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingRow(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTable createAlias(String alias) {
    return $SettingsTable(attachedDatabase, alias);
  }
}

class SettingRow extends DataClass implements Insertable<SettingRow> {
  final String key;
  final String value;
  const SettingRow({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsCompanion toCompanion(bool nullToAbsent) {
    return SettingsCompanion(key: Value(key), value: Value(value));
  }

  factory SettingRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingRow(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingRow copyWith({String? key, String? value}) =>
      SettingRow(key: key ?? this.key, value: value ?? this.value);
  SettingRow copyWithCompanion(SettingsCompanion data) {
    return SettingRow(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingRow(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingRow &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsCompanion extends UpdateCompanion<SettingRow> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingRow> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $TemplatesTable templates = $TemplatesTable(this);
  late final $TemplateExercisesTable templateExercises =
      $TemplateExercisesTable(this);
  late final $SessionsTable sessions = $SessionsTable(this);
  late final $SessionExercisesTable sessionExercises = $SessionExercisesTable(
    this,
  );
  late final $WorkoutSetsTable workoutSets = $WorkoutSetsTable(this);
  late final $PersonalRecordsTable personalRecords = $PersonalRecordsTable(
    this,
  );
  late final $DailyMetricsTable dailyMetrics = $DailyMetricsTable(this);
  late final $PhotosTable photos = $PhotosTable(this);
  late final $SettingsTable settings = $SettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercises,
    templates,
    templateExercises,
    sessions,
    sessionExercises,
    workoutSets,
    personalRecords,
    dailyMetrics,
    photos,
    settings,
  ];
}

typedef $$ExercisesTableCreateCompanionBuilder =
    ExercisesCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      required String id,
      required String name,
      required MuscleGroup muscleGroup,
      required ExerciseRole role,
      required int targetSets,
      required int repRangeMin,
      required int repRangeMax,
      required double incrementKg,
      Value<bool> isUnilateral,
      Value<bool> isBodyweight,
      Value<bool> isExplosive,
      Value<Muscle?> primaryMuscle,
      Value<Muscle?> secondaryMuscle,
      Value<String?> notes,
      Value<bool> isCustom,
      Value<bool> archived,
      Value<int> rowid,
    });
typedef $$ExercisesTableUpdateCompanionBuilder =
    ExercisesCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<String> id,
      Value<String> name,
      Value<MuscleGroup> muscleGroup,
      Value<ExerciseRole> role,
      Value<int> targetSets,
      Value<int> repRangeMin,
      Value<int> repRangeMax,
      Value<double> incrementKg,
      Value<bool> isUnilateral,
      Value<bool> isBodyweight,
      Value<bool> isExplosive,
      Value<Muscle?> primaryMuscle,
      Value<Muscle?> secondaryMuscle,
      Value<String?> notes,
      Value<bool> isCustom,
      Value<bool> archived,
      Value<int> rowid,
    });

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TemplateExercisesTable, List<TemplateExerciseRow>>
  _templateExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateExercises,
        aliasName: 'exercises__id__template_exercises__exercise_id',
      );

  $$TemplateExercisesTableProcessedTableManager get templateExercisesRefs {
    final manager = $$TemplateExercisesTableTableManager(
      $_db,
      $_db.templateExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExerciseRow>>
  _sessionExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionExercises,
    aliasName: 'exercises__id__session_exercises__exercise_id',
  );

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSetRow>>
  _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSets,
    aliasName: 'exercises__id__workout_sets__exercise_id',
  );

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager(
      $_db,
      $_db.workoutSets,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PersonalRecordsTable, List<PersonalRecordRow>>
  _personalRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.personalRecords,
    aliasName: 'exercises__id__personal_records__exercise_id',
  );

  $$PersonalRecordsTableProcessedTableManager get personalRecordsRefs {
    final manager = $$PersonalRecordsTableTableManager(
      $_db,
      $_db.personalRecords,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _personalRecordsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MuscleGroup, MuscleGroup, String>
  get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnWithTypeConverterFilters<ExerciseRole, ExerciseRole, String> get role =>
      $composableBuilder(
        column: $table.role,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repRangeMin => $composableBuilder(
    column: $table.repRangeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repRangeMax => $composableBuilder(
    column: $table.repRangeMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get incrementKg => $composableBuilder(
    column: $table.incrementKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isUnilateral => $composableBuilder(
    column: $table.isUnilateral,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBodyweight => $composableBuilder(
    column: $table.isBodyweight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isExplosive => $composableBuilder(
    column: $table.isExplosive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<Muscle?, Muscle, String> get primaryMuscle =>
      $composableBuilder(
        column: $table.primaryMuscle,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnWithTypeConverterFilters<Muscle?, Muscle, String> get secondaryMuscle =>
      $composableBuilder(
        column: $table.secondaryMuscle,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> templateExercisesRefs(
    Expression<bool> Function($$TemplateExercisesTableFilterComposer f) f,
  ) {
    final $$TemplateExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateExercisesTableFilterComposer(
            $db: $db,
            $table: $db.templateExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> sessionExercisesRefs(
    Expression<bool> Function($$SessionExercisesTableFilterComposer f) f,
  ) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSetsRefs(
    Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> personalRecordsRefs(
    Expression<bool> Function($$PersonalRecordsTableFilterComposer f) f,
  ) {
    final $$PersonalRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableFilterComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get muscleGroup => $composableBuilder(
    column: $table.muscleGroup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repRangeMin => $composableBuilder(
    column: $table.repRangeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repRangeMax => $composableBuilder(
    column: $table.repRangeMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get incrementKg => $composableBuilder(
    column: $table.incrementKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isUnilateral => $composableBuilder(
    column: $table.isUnilateral,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBodyweight => $composableBuilder(
    column: $table.isBodyweight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isExplosive => $composableBuilder(
    column: $table.isExplosive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get primaryMuscle => $composableBuilder(
    column: $table.primaryMuscle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscle => $composableBuilder(
    column: $table.secondaryMuscle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCustom => $composableBuilder(
    column: $table.isCustom,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get archived => $composableBuilder(
    column: $table.archived,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumnWithTypeConverter<MuscleGroup, String> get muscleGroup =>
      $composableBuilder(
        column: $table.muscleGroup,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<ExerciseRole, String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repRangeMin => $composableBuilder(
    column: $table.repRangeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repRangeMax => $composableBuilder(
    column: $table.repRangeMax,
    builder: (column) => column,
  );

  GeneratedColumn<double> get incrementKg => $composableBuilder(
    column: $table.incrementKg,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isUnilateral => $composableBuilder(
    column: $table.isUnilateral,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBodyweight => $composableBuilder(
    column: $table.isBodyweight,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isExplosive => $composableBuilder(
    column: $table.isExplosive,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<Muscle?, String> get primaryMuscle =>
      $composableBuilder(
        column: $table.primaryMuscle,
        builder: (column) => column,
      );

  GeneratedColumnWithTypeConverter<Muscle?, String> get secondaryMuscle =>
      $composableBuilder(
        column: $table.secondaryMuscle,
        builder: (column) => column,
      );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<bool> get archived =>
      $composableBuilder(column: $table.archived, builder: (column) => column);

  Expression<T> templateExercisesRefs<T extends Object>(
    Expression<T> Function($$TemplateExercisesTableAnnotationComposer a) f,
  ) {
    final $$TemplateExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateExercises,
          getReferencedColumn: (t) => t.exerciseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.templateExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> sessionExercisesRefs<T extends Object>(
    Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f,
  ) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> personalRecordsRefs<T extends Object>(
    Expression<T> Function($$PersonalRecordsTableAnnotationComposer a) f,
  ) {
    final $$PersonalRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.personalRecords,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PersonalRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.personalRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          ExerciseRow,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (ExerciseRow, $$ExercisesTableReferences),
          ExerciseRow,
          PrefetchHooks Function({
            bool templateExercisesRefs,
            bool sessionExercisesRefs,
            bool workoutSetsRefs,
            bool personalRecordsRefs,
          })
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<MuscleGroup> muscleGroup = const Value.absent(),
                Value<ExerciseRole> role = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int> repRangeMin = const Value.absent(),
                Value<int> repRangeMax = const Value.absent(),
                Value<double> incrementKg = const Value.absent(),
                Value<bool> isUnilateral = const Value.absent(),
                Value<bool> isBodyweight = const Value.absent(),
                Value<bool> isExplosive = const Value.absent(),
                Value<Muscle?> primaryMuscle = const Value.absent(),
                Value<Muscle?> secondaryMuscle = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                name: name,
                muscleGroup: muscleGroup,
                role: role,
                targetSets: targetSets,
                repRangeMin: repRangeMin,
                repRangeMax: repRangeMax,
                incrementKg: incrementKg,
                isUnilateral: isUnilateral,
                isBodyweight: isBodyweight,
                isExplosive: isExplosive,
                primaryMuscle: primaryMuscle,
                secondaryMuscle: secondaryMuscle,
                notes: notes,
                isCustom: isCustom,
                archived: archived,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String name,
                required MuscleGroup muscleGroup,
                required ExerciseRole role,
                required int targetSets,
                required int repRangeMin,
                required int repRangeMax,
                required double incrementKg,
                Value<bool> isUnilateral = const Value.absent(),
                Value<bool> isBodyweight = const Value.absent(),
                Value<bool> isExplosive = const Value.absent(),
                Value<Muscle?> primaryMuscle = const Value.absent(),
                Value<Muscle?> secondaryMuscle = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isCustom = const Value.absent(),
                Value<bool> archived = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                name: name,
                muscleGroup: muscleGroup,
                role: role,
                targetSets: targetSets,
                repRangeMin: repRangeMin,
                repRangeMax: repRangeMax,
                incrementKg: incrementKg,
                isUnilateral: isUnilateral,
                isBodyweight: isBodyweight,
                isExplosive: isExplosive,
                primaryMuscle: primaryMuscle,
                secondaryMuscle: secondaryMuscle,
                notes: notes,
                isCustom: isCustom,
                archived: archived,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                templateExercisesRefs = false,
                sessionExercisesRefs = false,
                workoutSetsRefs = false,
                personalRecordsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (templateExercisesRefs) db.templateExercises,
                    if (sessionExercisesRefs) db.sessionExercises,
                    if (workoutSetsRefs) db.workoutSets,
                    if (personalRecordsRefs) db.personalRecords,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (templateExercisesRefs)
                        await $_getPrefetchedData<
                          ExerciseRow,
                          $ExercisesTable,
                          TemplateExerciseRow
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._templateExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).templateExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (sessionExercisesRefs)
                        await $_getPrefetchedData<
                          ExerciseRow,
                          $ExercisesTable,
                          SessionExerciseRow
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._sessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutSetsRefs)
                        await $_getPrefetchedData<
                          ExerciseRow,
                          $ExercisesTable,
                          WorkoutSetRow
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._workoutSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (personalRecordsRefs)
                        await $_getPrefetchedData<
                          ExerciseRow,
                          $ExercisesTable,
                          PersonalRecordRow
                        >(
                          currentTable: table,
                          referencedTable: $$ExercisesTableReferences
                              ._personalRecordsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ExercisesTableReferences(
                                db,
                                table,
                                p0,
                              ).personalRecordsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.exerciseId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      ExerciseRow,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (ExerciseRow, $$ExercisesTableReferences),
      ExerciseRow,
      PrefetchHooks Function({
        bool templateExercisesRefs,
        bool sessionExercisesRefs,
        bool workoutSetsRefs,
        bool personalRecordsRefs,
      })
    >;
typedef $$TemplatesTableCreateCompanionBuilder =
    TemplatesCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      required String id,
      required String name,
      Value<int?> weekday,
      Value<String?> cardioLabel,
      Value<String?> accentHex,
      Value<int> orderIndex,
      Value<int> rowid,
    });
typedef $$TemplatesTableUpdateCompanionBuilder =
    TemplatesCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<String> id,
      Value<String> name,
      Value<int?> weekday,
      Value<String?> cardioLabel,
      Value<String?> accentHex,
      Value<int> orderIndex,
      Value<int> rowid,
    });

final class $$TemplatesTableReferences
    extends BaseReferences<_$AppDatabase, $TemplatesTable, TemplateRow> {
  $$TemplatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$TemplateExercisesTable, List<TemplateExerciseRow>>
  _templateExercisesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.templateExercises,
        aliasName: 'templates__id__template_exercises__template_id',
      );

  $$TemplateExercisesTableProcessedTableManager get templateExercisesRefs {
    final manager = $$TemplateExercisesTableTableManager(
      $_db,
      $_db.templateExercises,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _templateExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get cardioLabel => $composableBuilder(
    column: $table.cardioLabel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accentHex => $composableBuilder(
    column: $table.accentHex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> templateExercisesRefs(
    Expression<bool> Function($$TemplateExercisesTableFilterComposer f) f,
  ) {
    final $$TemplateExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.templateExercises,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplateExercisesTableFilterComposer(
            $db: $db,
            $table: $db.templateExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekday => $composableBuilder(
    column: $table.weekday,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get cardioLabel => $composableBuilder(
    column: $table.cardioLabel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accentHex => $composableBuilder(
    column: $table.accentHex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplatesTable> {
  $$TemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get weekday =>
      $composableBuilder(column: $table.weekday, builder: (column) => column);

  GeneratedColumn<String> get cardioLabel => $composableBuilder(
    column: $table.cardioLabel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get accentHex =>
      $composableBuilder(column: $table.accentHex, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  Expression<T> templateExercisesRefs<T extends Object>(
    Expression<T> Function($$TemplateExercisesTableAnnotationComposer a) f,
  ) {
    final $$TemplateExercisesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.templateExercises,
          getReferencedColumn: (t) => t.templateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$TemplateExercisesTableAnnotationComposer(
                $db: $db,
                $table: $db.templateExercises,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$TemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplatesTable,
          TemplateRow,
          $$TemplatesTableFilterComposer,
          $$TemplatesTableOrderingComposer,
          $$TemplatesTableAnnotationComposer,
          $$TemplatesTableCreateCompanionBuilder,
          $$TemplatesTableUpdateCompanionBuilder,
          (TemplateRow, $$TemplatesTableReferences),
          TemplateRow,
          PrefetchHooks Function({bool templateExercisesRefs})
        > {
  $$TemplatesTableTableManager(_$AppDatabase db, $TemplatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int?> weekday = const Value.absent(),
                Value<String?> cardioLabel = const Value.absent(),
                Value<String?> accentHex = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplatesCompanion(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                name: name,
                weekday: weekday,
                cardioLabel: cardioLabel,
                accentHex: accentHex,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String name,
                Value<int?> weekday = const Value.absent(),
                Value<String?> cardioLabel = const Value.absent(),
                Value<String?> accentHex = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplatesCompanion.insert(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                name: name,
                weekday: weekday,
                cardioLabel: cardioLabel,
                accentHex: accentHex,
                orderIndex: orderIndex,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateExercisesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (templateExercisesRefs) db.templateExercises,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (templateExercisesRefs)
                    await $_getPrefetchedData<
                      TemplateRow,
                      $TemplatesTable,
                      TemplateExerciseRow
                    >(
                      currentTable: table,
                      referencedTable: $$TemplatesTableReferences
                          ._templateExercisesRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).templateExercisesRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.templateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplatesTable,
      TemplateRow,
      $$TemplatesTableFilterComposer,
      $$TemplatesTableOrderingComposer,
      $$TemplatesTableAnnotationComposer,
      $$TemplatesTableCreateCompanionBuilder,
      $$TemplatesTableUpdateCompanionBuilder,
      (TemplateRow, $$TemplatesTableReferences),
      TemplateRow,
      PrefetchHooks Function({bool templateExercisesRefs})
    >;
typedef $$TemplateExercisesTableCreateCompanionBuilder =
    TemplateExercisesCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      required String id,
      required String templateId,
      required String exerciseId,
      required int orderIndex,
      Value<int?> setsOverride,
      Value<int?> repMinOverride,
      Value<int?> repMaxOverride,
      Value<int?> supersetGroup,
      Value<int> rowid,
    });
typedef $$TemplateExercisesTableUpdateCompanionBuilder =
    TemplateExercisesCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<String> id,
      Value<String> templateId,
      Value<String> exerciseId,
      Value<int> orderIndex,
      Value<int?> setsOverride,
      Value<int?> repMinOverride,
      Value<int?> repMaxOverride,
      Value<int?> supersetGroup,
      Value<int> rowid,
    });

final class $$TemplateExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $TemplateExercisesTable,
          TemplateExerciseRow
        > {
  $$TemplateExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $TemplatesTable _templateIdTable(_$AppDatabase db) => db.templates
      .createAlias('template_exercises__template_id__templates__id');

  $$TemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<String>('template_id')!;

    final manager = $$TemplatesTableTableManager(
      $_db,
      $_db.templates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) => db.exercises
      .createAlias('template_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$TemplateExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $TemplateExercisesTable> {
  $$TemplateExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setsOverride => $composableBuilder(
    column: $table.setsOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repMinOverride => $composableBuilder(
    column: $table.repMinOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repMaxOverride => $composableBuilder(
    column: $table.repMaxOverride,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnFilters(column),
  );

  $$TemplatesTableFilterComposer get templateId {
    final $$TemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.templates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplatesTableFilterComposer(
            $db: $db,
            $table: $db.templates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $TemplateExercisesTable> {
  $$TemplateExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setsOverride => $composableBuilder(
    column: $table.setsOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repMinOverride => $composableBuilder(
    column: $table.repMinOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repMaxOverride => $composableBuilder(
    column: $table.repMaxOverride,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnOrderings(column),
  );

  $$TemplatesTableOrderingComposer get templateId {
    final $$TemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.templates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.templates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $TemplateExercisesTable> {
  $$TemplateExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get setsOverride => $composableBuilder(
    column: $table.setsOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repMinOverride => $composableBuilder(
    column: $table.repMinOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repMaxOverride => $composableBuilder(
    column: $table.repMaxOverride,
    builder: (column) => column,
  );

  GeneratedColumn<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => column,
  );

  $$TemplatesTableAnnotationComposer get templateId {
    final $$TemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.templates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.templates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TemplateExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TemplateExercisesTable,
          TemplateExerciseRow,
          $$TemplateExercisesTableFilterComposer,
          $$TemplateExercisesTableOrderingComposer,
          $$TemplateExercisesTableAnnotationComposer,
          $$TemplateExercisesTableCreateCompanionBuilder,
          $$TemplateExercisesTableUpdateCompanionBuilder,
          (TemplateExerciseRow, $$TemplateExercisesTableReferences),
          TemplateExerciseRow,
          PrefetchHooks Function({bool templateId, bool exerciseId})
        > {
  $$TemplateExercisesTableTableManager(
    _$AppDatabase db,
    $TemplateExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TemplateExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TemplateExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TemplateExercisesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> templateId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int?> setsOverride = const Value.absent(),
                Value<int?> repMinOverride = const Value.absent(),
                Value<int?> repMaxOverride = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplateExercisesCompanion(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                setsOverride: setsOverride,
                repMinOverride: repMinOverride,
                repMaxOverride: repMaxOverride,
                supersetGroup: supersetGroup,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String templateId,
                required String exerciseId,
                required int orderIndex,
                Value<int?> setsOverride = const Value.absent(),
                Value<int?> repMinOverride = const Value.absent(),
                Value<int?> repMaxOverride = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TemplateExercisesCompanion.insert(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                templateId: templateId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                setsOverride: setsOverride,
                repMinOverride: repMinOverride,
                repMaxOverride: repMaxOverride,
                supersetGroup: supersetGroup,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TemplateExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({templateId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (templateId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.templateId,
                                referencedTable:
                                    $$TemplateExercisesTableReferences
                                        ._templateIdTable(db),
                                referencedColumn:
                                    $$TemplateExercisesTableReferences
                                        ._templateIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$TemplateExercisesTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$TemplateExercisesTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$TemplateExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TemplateExercisesTable,
      TemplateExerciseRow,
      $$TemplateExercisesTableFilterComposer,
      $$TemplateExercisesTableOrderingComposer,
      $$TemplateExercisesTableAnnotationComposer,
      $$TemplateExercisesTableCreateCompanionBuilder,
      $$TemplateExercisesTableUpdateCompanionBuilder,
      (TemplateExerciseRow, $$TemplateExercisesTableReferences),
      TemplateExerciseRow,
      PrefetchHooks Function({bool templateId, bool exerciseId})
    >;
typedef $$SessionsTableCreateCompanionBuilder =
    SessionsCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      required String id,
      required DateTime date,
      Value<String?> templateId,
      Value<String?> templateName,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationMin,
      Value<double> tonnageKg,
      Value<int> totalSets,
      Value<bool> cardioDone,
      Value<bool> saunaDone,
      Value<String?> notes,
      Value<bool> isComplete,
      Value<bool> durationSuspect,
      Value<int> rowid,
    });
typedef $$SessionsTableUpdateCompanionBuilder =
    SessionsCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<String> id,
      Value<DateTime> date,
      Value<String?> templateId,
      Value<String?> templateName,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
      Value<int> durationMin,
      Value<double> tonnageKg,
      Value<int> totalSets,
      Value<bool> cardioDone,
      Value<bool> saunaDone,
      Value<String?> notes,
      Value<bool> isComplete,
      Value<bool> durationSuspect,
      Value<int> rowid,
    });

final class $$SessionsTableReferences
    extends BaseReferences<_$AppDatabase, $SessionsTable, SessionRow> {
  $$SessionsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SessionExercisesTable, List<SessionExerciseRow>>
  _sessionExercisesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.sessionExercises,
    aliasName: 'sessions__id__session_exercises__session_id',
  );

  $$SessionExercisesTableProcessedTableManager get sessionExercisesRefs {
    final manager = $$SessionExercisesTableTableManager(
      $_db,
      $_db.sessionExercises,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _sessionExercisesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$WorkoutSetsTable, List<WorkoutSetRow>>
  _workoutSetsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.workoutSets,
    aliasName: 'sessions__id__workout_sets__session_id',
  );

  $$WorkoutSetsTableProcessedTableManager get workoutSetsRefs {
    final manager = $$WorkoutSetsTableTableManager(
      $_db,
      $_db.workoutSets,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_workoutSetsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SessionsTableFilterComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get tonnageKg => $composableBuilder(
    column: $table.tonnageKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalSets => $composableBuilder(
    column: $table.totalSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get cardioDone => $composableBuilder(
    column: $table.cardioDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get saunaDone => $composableBuilder(
    column: $table.saunaDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get durationSuspect => $composableBuilder(
    column: $table.durationSuspect,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> sessionExercisesRefs(
    Expression<bool> Function($$SessionExercisesTableFilterComposer f) f,
  ) {
    final $$SessionExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableFilterComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> workoutSetsRefs(
    Expression<bool> Function($$WorkoutSetsTableFilterComposer f) f,
  ) {
    final $$WorkoutSetsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get tonnageKg => $composableBuilder(
    column: $table.tonnageKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalSets => $composableBuilder(
    column: $table.totalSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get cardioDone => $composableBuilder(
    column: $table.cardioDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get saunaDone => $composableBuilder(
    column: $table.saunaDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get durationSuspect => $composableBuilder(
    column: $table.durationSuspect,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionsTable> {
  $$SessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get templateName => $composableBuilder(
    column: $table.templateName,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<int> get durationMin => $composableBuilder(
    column: $table.durationMin,
    builder: (column) => column,
  );

  GeneratedColumn<double> get tonnageKg =>
      $composableBuilder(column: $table.tonnageKg, builder: (column) => column);

  GeneratedColumn<int> get totalSets =>
      $composableBuilder(column: $table.totalSets, builder: (column) => column);

  GeneratedColumn<bool> get cardioDone => $composableBuilder(
    column: $table.cardioDone,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get saunaDone =>
      $composableBuilder(column: $table.saunaDone, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isComplete => $composableBuilder(
    column: $table.isComplete,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get durationSuspect => $composableBuilder(
    column: $table.durationSuspect,
    builder: (column) => column,
  );

  Expression<T> sessionExercisesRefs<T extends Object>(
    Expression<T> Function($$SessionExercisesTableAnnotationComposer a) f,
  ) {
    final $$SessionExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.sessionExercises,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.sessionExercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> workoutSetsRefs<T extends Object>(
    Expression<T> Function($$WorkoutSetsTableAnnotationComposer a) f,
  ) {
    final $$WorkoutSetsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.workoutSets,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSetsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSets,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionsTable,
          SessionRow,
          $$SessionsTableFilterComposer,
          $$SessionsTableOrderingComposer,
          $$SessionsTableAnnotationComposer,
          $$SessionsTableCreateCompanionBuilder,
          $$SessionsTableUpdateCompanionBuilder,
          (SessionRow, $$SessionsTableReferences),
          SessionRow,
          PrefetchHooks Function({
            bool sessionExercisesRefs,
            bool workoutSetsRefs,
          })
        > {
  $$SessionsTableTableManager(_$AppDatabase db, $SessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> templateId = const Value.absent(),
                Value<String?> templateName = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<double> tonnageKg = const Value.absent(),
                Value<int> totalSets = const Value.absent(),
                Value<bool> cardioDone = const Value.absent(),
                Value<bool> saunaDone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<bool> durationSuspect = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                date: date,
                templateId: templateId,
                templateName: templateName,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMin: durationMin,
                tonnageKg: tonnageKg,
                totalSets: totalSets,
                cardioDone: cardioDone,
                saunaDone: saunaDone,
                notes: notes,
                isComplete: isComplete,
                durationSuspect: durationSuspect,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String id,
                required DateTime date,
                Value<String?> templateId = const Value.absent(),
                Value<String?> templateName = const Value.absent(),
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
                Value<int> durationMin = const Value.absent(),
                Value<double> tonnageKg = const Value.absent(),
                Value<int> totalSets = const Value.absent(),
                Value<bool> cardioDone = const Value.absent(),
                Value<bool> saunaDone = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isComplete = const Value.absent(),
                Value<bool> durationSuspect = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionsCompanion.insert(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                date: date,
                templateId: templateId,
                templateName: templateName,
                startedAt: startedAt,
                endedAt: endedAt,
                durationMin: durationMin,
                tonnageKg: tonnageKg,
                totalSets: totalSets,
                cardioDone: cardioDone,
                saunaDone: saunaDone,
                notes: notes,
                isComplete: isComplete,
                durationSuspect: durationSuspect,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({sessionExercisesRefs = false, workoutSetsRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (sessionExercisesRefs) db.sessionExercises,
                    if (workoutSetsRefs) db.workoutSets,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (sessionExercisesRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          SessionExerciseRow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._sessionExercisesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).sessionExercisesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (workoutSetsRefs)
                        await $_getPrefetchedData<
                          SessionRow,
                          $SessionsTable,
                          WorkoutSetRow
                        >(
                          currentTable: table,
                          referencedTable: $$SessionsTableReferences
                              ._workoutSetsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SessionsTableReferences(
                                db,
                                table,
                                p0,
                              ).workoutSetsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.sessionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionsTable,
      SessionRow,
      $$SessionsTableFilterComposer,
      $$SessionsTableOrderingComposer,
      $$SessionsTableAnnotationComposer,
      $$SessionsTableCreateCompanionBuilder,
      $$SessionsTableUpdateCompanionBuilder,
      (SessionRow, $$SessionsTableReferences),
      SessionRow,
      PrefetchHooks Function({bool sessionExercisesRefs, bool workoutSetsRefs})
    >;
typedef $$SessionExercisesTableCreateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      required String id,
      required String sessionId,
      required String exerciseId,
      required int orderIndex,
      required int targetSets,
      required int repRangeMin,
      required int repRangeMax,
      Value<double?> suggestedWeightKg,
      Value<bool> increaseFlagged,
      Value<String?> notes,
      Value<int?> supersetGroup,
      Value<int> rowid,
    });
typedef $$SessionExercisesTableUpdateCompanionBuilder =
    SessionExercisesCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<String> id,
      Value<String> sessionId,
      Value<String> exerciseId,
      Value<int> orderIndex,
      Value<int> targetSets,
      Value<int> repRangeMin,
      Value<int> repRangeMax,
      Value<double?> suggestedWeightKg,
      Value<bool> increaseFlagged,
      Value<String?> notes,
      Value<int?> supersetGroup,
      Value<int> rowid,
    });

final class $$SessionExercisesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $SessionExercisesTable,
          SessionExerciseRow
        > {
  $$SessionExercisesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('session_exercises__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('session_exercises__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$SessionExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repRangeMin => $composableBuilder(
    column: $table.repRangeMin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repRangeMax => $composableBuilder(
    column: $table.repRangeMax,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get suggestedWeightKg => $composableBuilder(
    column: $table.suggestedWeightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get increaseFlagged => $composableBuilder(
    column: $table.increaseFlagged,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repRangeMin => $composableBuilder(
    column: $table.repRangeMin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repRangeMax => $composableBuilder(
    column: $table.repRangeMax,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get suggestedWeightKg => $composableBuilder(
    column: $table.suggestedWeightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get increaseFlagged => $composableBuilder(
    column: $table.increaseFlagged,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SessionExercisesTable> {
  $$SessionExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get orderIndex => $composableBuilder(
    column: $table.orderIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repRangeMin => $composableBuilder(
    column: $table.repRangeMin,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repRangeMax => $composableBuilder(
    column: $table.repRangeMax,
    builder: (column) => column,
  );

  GeneratedColumn<double> get suggestedWeightKg => $composableBuilder(
    column: $table.suggestedWeightKg,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get increaseFlagged => $composableBuilder(
    column: $table.increaseFlagged,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get supersetGroup => $composableBuilder(
    column: $table.supersetGroup,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$SessionExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SessionExercisesTable,
          SessionExerciseRow,
          $$SessionExercisesTableFilterComposer,
          $$SessionExercisesTableOrderingComposer,
          $$SessionExercisesTableAnnotationComposer,
          $$SessionExercisesTableCreateCompanionBuilder,
          $$SessionExercisesTableUpdateCompanionBuilder,
          (SessionExerciseRow, $$SessionExercisesTableReferences),
          SessionExerciseRow,
          PrefetchHooks Function({bool sessionId, bool exerciseId})
        > {
  $$SessionExercisesTableTableManager(
    _$AppDatabase db,
    $SessionExercisesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SessionExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SessionExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SessionExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> orderIndex = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int> repRangeMin = const Value.absent(),
                Value<int> repRangeMax = const Value.absent(),
                Value<double?> suggestedWeightKg = const Value.absent(),
                Value<bool> increaseFlagged = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExercisesCompanion(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                targetSets: targetSets,
                repRangeMin: repRangeMin,
                repRangeMax: repRangeMax,
                suggestedWeightKg: suggestedWeightKg,
                increaseFlagged: increaseFlagged,
                notes: notes,
                supersetGroup: supersetGroup,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String sessionId,
                required String exerciseId,
                required int orderIndex,
                required int targetSets,
                required int repRangeMin,
                required int repRangeMax,
                Value<double?> suggestedWeightKg = const Value.absent(),
                Value<bool> increaseFlagged = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> supersetGroup = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SessionExercisesCompanion.insert(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                orderIndex: orderIndex,
                targetSets: targetSets,
                repRangeMin: repRangeMin,
                repRangeMax: repRangeMax,
                suggestedWeightKg: suggestedWeightKg,
                increaseFlagged: increaseFlagged,
                notes: notes,
                supersetGroup: supersetGroup,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SessionExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable:
                                    $$SessionExercisesTableReferences
                                        ._sessionIdTable(db),
                                referencedColumn:
                                    $$SessionExercisesTableReferences
                                        ._sessionIdTable(db)
                                        .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$SessionExercisesTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$SessionExercisesTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$SessionExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SessionExercisesTable,
      SessionExerciseRow,
      $$SessionExercisesTableFilterComposer,
      $$SessionExercisesTableOrderingComposer,
      $$SessionExercisesTableAnnotationComposer,
      $$SessionExercisesTableCreateCompanionBuilder,
      $$SessionExercisesTableUpdateCompanionBuilder,
      (SessionExerciseRow, $$SessionExercisesTableReferences),
      SessionExerciseRow,
      PrefetchHooks Function({bool sessionId, bool exerciseId})
    >;
typedef $$WorkoutSetsTableCreateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      required String id,
      required String sessionId,
      required String exerciseId,
      required int setNo,
      required double weightKg,
      required int reps,
      Value<int?> rpe,
      Value<String?> note,
      Value<bool> isPr,
      Value<bool> isWarmup,
      required DateTime completedAt,
      Value<int> rowid,
    });
typedef $$WorkoutSetsTableUpdateCompanionBuilder =
    WorkoutSetsCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<String> id,
      Value<String> sessionId,
      Value<String> exerciseId,
      Value<int> setNo,
      Value<double> weightKg,
      Value<int> reps,
      Value<int?> rpe,
      Value<String?> note,
      Value<bool> isPr,
      Value<bool> isWarmup,
      Value<DateTime> completedAt,
      Value<int> rowid,
    });

final class $$WorkoutSetsTableReferences
    extends BaseReferences<_$AppDatabase, $WorkoutSetsTable, WorkoutSetRow> {
  $$WorkoutSetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SessionsTable _sessionIdTable(_$AppDatabase db) =>
      db.sessions.createAlias('workout_sets__session_id__sessions__id');

  $$SessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<String>('session_id')!;

    final manager = $$SessionsTableTableManager(
      $_db,
      $_db.sessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('workout_sets__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$WorkoutSetsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get setNo => $composableBuilder(
    column: $table.setNo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isPr => $composableBuilder(
    column: $table.isPr,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SessionsTableFilterComposer get sessionId {
    final $$SessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableFilterComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get setNo => $composableBuilder(
    column: $table.setNo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isPr => $composableBuilder(
    column: $table.isPr,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isWarmup => $composableBuilder(
    column: $table.isWarmup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SessionsTableOrderingComposer get sessionId {
    final $$SessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableOrderingComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSetsTable> {
  $$WorkoutSetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get setNo =>
      $composableBuilder(column: $table.setNo, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<int> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<bool> get isPr =>
      $composableBuilder(column: $table.isPr, builder: (column) => column);

  GeneratedColumn<bool> get isWarmup =>
      $composableBuilder(column: $table.isWarmup, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  $$SessionsTableAnnotationComposer get sessionId {
    final $$SessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.sessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.sessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$WorkoutSetsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSetsTable,
          WorkoutSetRow,
          $$WorkoutSetsTableFilterComposer,
          $$WorkoutSetsTableOrderingComposer,
          $$WorkoutSetsTableAnnotationComposer,
          $$WorkoutSetsTableCreateCompanionBuilder,
          $$WorkoutSetsTableUpdateCompanionBuilder,
          (WorkoutSetRow, $$WorkoutSetsTableReferences),
          WorkoutSetRow,
          PrefetchHooks Function({bool sessionId, bool exerciseId})
        > {
  $$WorkoutSetsTableTableManager(_$AppDatabase db, $WorkoutSetsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> sessionId = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<int> setNo = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<int?> rpe = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isPr = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSetsCompanion(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                setNo: setNo,
                weightKg: weightKg,
                reps: reps,
                rpe: rpe,
                note: note,
                isPr: isPr,
                isWarmup: isWarmup,
                completedAt: completedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String sessionId,
                required String exerciseId,
                required int setNo,
                required double weightKg,
                required int reps,
                Value<int?> rpe = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<bool> isPr = const Value.absent(),
                Value<bool> isWarmup = const Value.absent(),
                required DateTime completedAt,
                Value<int> rowid = const Value.absent(),
              }) => WorkoutSetsCompanion.insert(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                sessionId: sessionId,
                exerciseId: exerciseId,
                setNo: setNo,
                weightKg: weightKg,
                reps: reps,
                rpe: rpe,
                note: note,
                isPr: isPr,
                isWarmup: isWarmup,
                completedAt: completedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$WorkoutSetsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false, exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.sessionId,
                                referencedTable: $$WorkoutSetsTableReferences
                                    ._sessionIdTable(db),
                                referencedColumn: $$WorkoutSetsTableReferences
                                    ._sessionIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable: $$WorkoutSetsTableReferences
                                    ._exerciseIdTable(db),
                                referencedColumn: $$WorkoutSetsTableReferences
                                    ._exerciseIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSetsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSetsTable,
      WorkoutSetRow,
      $$WorkoutSetsTableFilterComposer,
      $$WorkoutSetsTableOrderingComposer,
      $$WorkoutSetsTableAnnotationComposer,
      $$WorkoutSetsTableCreateCompanionBuilder,
      $$WorkoutSetsTableUpdateCompanionBuilder,
      (WorkoutSetRow, $$WorkoutSetsTableReferences),
      WorkoutSetRow,
      PrefetchHooks Function({bool sessionId, bool exerciseId})
    >;
typedef $$PersonalRecordsTableCreateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      required String id,
      required String exerciseId,
      Value<String?> setId,
      Value<String?> sessionId,
      required PrType type,
      required double value,
      required double weightKg,
      required int reps,
      Value<double?> previousValue,
      required DateTime achievedAt,
      Value<int> rowid,
    });
typedef $$PersonalRecordsTableUpdateCompanionBuilder =
    PersonalRecordsCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<String> id,
      Value<String> exerciseId,
      Value<String?> setId,
      Value<String?> sessionId,
      Value<PrType> type,
      Value<double> value,
      Value<double> weightKg,
      Value<int> reps,
      Value<double?> previousValue,
      Value<DateTime> achievedAt,
      Value<int> rowid,
    });

final class $$PersonalRecordsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecordRow
        > {
  $$PersonalRecordsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('personal_records__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PersonalRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PrType, PrType, String> get type =>
      $composableBuilder(
        column: $table.type,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get previousValue => $composableBuilder(
    column: $table.previousValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get setId => $composableBuilder(
    column: $table.setId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sessionId => $composableBuilder(
    column: $table.sessionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get previousValue => $composableBuilder(
    column: $table.previousValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PersonalRecordsTable> {
  $$PersonalRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get setId =>
      $composableBuilder(column: $table.setId, builder: (column) => column);

  GeneratedColumn<String> get sessionId =>
      $composableBuilder(column: $table.sessionId, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PrType, String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<double> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get previousValue => $composableBuilder(
    column: $table.previousValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get achievedAt => $composableBuilder(
    column: $table.achievedAt,
    builder: (column) => column,
  );

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PersonalRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PersonalRecordsTable,
          PersonalRecordRow,
          $$PersonalRecordsTableFilterComposer,
          $$PersonalRecordsTableOrderingComposer,
          $$PersonalRecordsTableAnnotationComposer,
          $$PersonalRecordsTableCreateCompanionBuilder,
          $$PersonalRecordsTableUpdateCompanionBuilder,
          (PersonalRecordRow, $$PersonalRecordsTableReferences),
          PersonalRecordRow,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$PersonalRecordsTableTableManager(
    _$AppDatabase db,
    $PersonalRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PersonalRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PersonalRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PersonalRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String?> setId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                Value<PrType> type = const Value.absent(),
                Value<double> value = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<double?> previousValue = const Value.absent(),
                Value<DateTime> achievedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                exerciseId: exerciseId,
                setId: setId,
                sessionId: sessionId,
                type: type,
                value: value,
                weightKg: weightKg,
                reps: reps,
                previousValue: previousValue,
                achievedAt: achievedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String id,
                required String exerciseId,
                Value<String?> setId = const Value.absent(),
                Value<String?> sessionId = const Value.absent(),
                required PrType type,
                required double value,
                required double weightKg,
                required int reps,
                Value<double?> previousValue = const Value.absent(),
                required DateTime achievedAt,
                Value<int> rowid = const Value.absent(),
              }) => PersonalRecordsCompanion.insert(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                exerciseId: exerciseId,
                setId: setId,
                sessionId: sessionId,
                type: type,
                value: value,
                weightKg: weightKg,
                reps: reps,
                previousValue: previousValue,
                achievedAt: achievedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PersonalRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.exerciseId,
                                referencedTable:
                                    $$PersonalRecordsTableReferences
                                        ._exerciseIdTable(db),
                                referencedColumn:
                                    $$PersonalRecordsTableReferences
                                        ._exerciseIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PersonalRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PersonalRecordsTable,
      PersonalRecordRow,
      $$PersonalRecordsTableFilterComposer,
      $$PersonalRecordsTableOrderingComposer,
      $$PersonalRecordsTableAnnotationComposer,
      $$PersonalRecordsTableCreateCompanionBuilder,
      $$PersonalRecordsTableUpdateCompanionBuilder,
      (PersonalRecordRow, $$PersonalRecordsTableReferences),
      PersonalRecordRow,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$DailyMetricsTableCreateCompanionBuilder =
    DailyMetricsCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      required DateTime date,
      Value<double?> weightKg,
      Value<int?> steps,
      Value<int> waterMl,
      Value<int?> kcal,
      Value<int?> proteinG,
      Value<double?> sleepHours,
      Value<double?> chestCm,
      Value<double?> waistCm,
      Value<double?> hipsCm,
      Value<double?> armCm,
      Value<double?> thighCm,
      Value<double?> neckCm,
      Value<bool> stepsFromHealth,
      Value<bool> sleepFromHealth,
      Value<bool> weightFromHealth,
      Value<int> rowid,
    });
typedef $$DailyMetricsTableUpdateCompanionBuilder =
    DailyMetricsCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<DateTime> date,
      Value<double?> weightKg,
      Value<int?> steps,
      Value<int> waterMl,
      Value<int?> kcal,
      Value<int?> proteinG,
      Value<double?> sleepHours,
      Value<double?> chestCm,
      Value<double?> waistCm,
      Value<double?> hipsCm,
      Value<double?> armCm,
      Value<double?> thighCm,
      Value<double?> neckCm,
      Value<bool> stepsFromHealth,
      Value<bool> sleepFromHealth,
      Value<bool> weightFromHealth,
      Value<int> rowid,
    });

class $$DailyMetricsTableFilterComposer
    extends Composer<_$AppDatabase, $DailyMetricsTable> {
  $$DailyMetricsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get waterMl => $composableBuilder(
    column: $table.waterMl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get armCm => $composableBuilder(
    column: $table.armCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get thighCm => $composableBuilder(
    column: $table.thighCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get stepsFromHealth => $composableBuilder(
    column: $table.stepsFromHealth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get sleepFromHealth => $composableBuilder(
    column: $table.sleepFromHealth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get weightFromHealth => $composableBuilder(
    column: $table.weightFromHealth,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DailyMetricsTableOrderingComposer
    extends Composer<_$AppDatabase, $DailyMetricsTable> {
  $$DailyMetricsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get waterMl => $composableBuilder(
    column: $table.waterMl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get kcal => $composableBuilder(
    column: $table.kcal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get proteinG => $composableBuilder(
    column: $table.proteinG,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get chestCm => $composableBuilder(
    column: $table.chestCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get waistCm => $composableBuilder(
    column: $table.waistCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get hipsCm => $composableBuilder(
    column: $table.hipsCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get armCm => $composableBuilder(
    column: $table.armCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get thighCm => $composableBuilder(
    column: $table.thighCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get neckCm => $composableBuilder(
    column: $table.neckCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get stepsFromHealth => $composableBuilder(
    column: $table.stepsFromHealth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get sleepFromHealth => $composableBuilder(
    column: $table.sleepFromHealth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get weightFromHealth => $composableBuilder(
    column: $table.weightFromHealth,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DailyMetricsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DailyMetricsTable> {
  $$DailyMetricsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  GeneratedColumn<int> get waterMl =>
      $composableBuilder(column: $table.waterMl, builder: (column) => column);

  GeneratedColumn<int> get kcal =>
      $composableBuilder(column: $table.kcal, builder: (column) => column);

  GeneratedColumn<int> get proteinG =>
      $composableBuilder(column: $table.proteinG, builder: (column) => column);

  GeneratedColumn<double> get sleepHours => $composableBuilder(
    column: $table.sleepHours,
    builder: (column) => column,
  );

  GeneratedColumn<double> get chestCm =>
      $composableBuilder(column: $table.chestCm, builder: (column) => column);

  GeneratedColumn<double> get waistCm =>
      $composableBuilder(column: $table.waistCm, builder: (column) => column);

  GeneratedColumn<double> get hipsCm =>
      $composableBuilder(column: $table.hipsCm, builder: (column) => column);

  GeneratedColumn<double> get armCm =>
      $composableBuilder(column: $table.armCm, builder: (column) => column);

  GeneratedColumn<double> get thighCm =>
      $composableBuilder(column: $table.thighCm, builder: (column) => column);

  GeneratedColumn<double> get neckCm =>
      $composableBuilder(column: $table.neckCm, builder: (column) => column);

  GeneratedColumn<bool> get stepsFromHealth => $composableBuilder(
    column: $table.stepsFromHealth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get sleepFromHealth => $composableBuilder(
    column: $table.sleepFromHealth,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get weightFromHealth => $composableBuilder(
    column: $table.weightFromHealth,
    builder: (column) => column,
  );
}

class $$DailyMetricsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DailyMetricsTable,
          DailyMetricRow,
          $$DailyMetricsTableFilterComposer,
          $$DailyMetricsTableOrderingComposer,
          $$DailyMetricsTableAnnotationComposer,
          $$DailyMetricsTableCreateCompanionBuilder,
          $$DailyMetricsTableUpdateCompanionBuilder,
          (
            DailyMetricRow,
            BaseReferences<_$AppDatabase, $DailyMetricsTable, DailyMetricRow>,
          ),
          DailyMetricRow,
          PrefetchHooks Function()
        > {
  $$DailyMetricsTableTableManager(_$AppDatabase db, $DailyMetricsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DailyMetricsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DailyMetricsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DailyMetricsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<double?> weightKg = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<int> waterMl = const Value.absent(),
                Value<int?> kcal = const Value.absent(),
                Value<int?> proteinG = const Value.absent(),
                Value<double?> sleepHours = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<double?> armCm = const Value.absent(),
                Value<double?> thighCm = const Value.absent(),
                Value<double?> neckCm = const Value.absent(),
                Value<bool> stepsFromHealth = const Value.absent(),
                Value<bool> sleepFromHealth = const Value.absent(),
                Value<bool> weightFromHealth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyMetricsCompanion(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                date: date,
                weightKg: weightKg,
                steps: steps,
                waterMl: waterMl,
                kcal: kcal,
                proteinG: proteinG,
                sleepHours: sleepHours,
                chestCm: chestCm,
                waistCm: waistCm,
                hipsCm: hipsCm,
                armCm: armCm,
                thighCm: thighCm,
                neckCm: neckCm,
                stepsFromHealth: stepsFromHealth,
                sleepFromHealth: sleepFromHealth,
                weightFromHealth: weightFromHealth,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required DateTime date,
                Value<double?> weightKg = const Value.absent(),
                Value<int?> steps = const Value.absent(),
                Value<int> waterMl = const Value.absent(),
                Value<int?> kcal = const Value.absent(),
                Value<int?> proteinG = const Value.absent(),
                Value<double?> sleepHours = const Value.absent(),
                Value<double?> chestCm = const Value.absent(),
                Value<double?> waistCm = const Value.absent(),
                Value<double?> hipsCm = const Value.absent(),
                Value<double?> armCm = const Value.absent(),
                Value<double?> thighCm = const Value.absent(),
                Value<double?> neckCm = const Value.absent(),
                Value<bool> stepsFromHealth = const Value.absent(),
                Value<bool> sleepFromHealth = const Value.absent(),
                Value<bool> weightFromHealth = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DailyMetricsCompanion.insert(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                date: date,
                weightKg: weightKg,
                steps: steps,
                waterMl: waterMl,
                kcal: kcal,
                proteinG: proteinG,
                sleepHours: sleepHours,
                chestCm: chestCm,
                waistCm: waistCm,
                hipsCm: hipsCm,
                armCm: armCm,
                thighCm: thighCm,
                neckCm: neckCm,
                stepsFromHealth: stepsFromHealth,
                sleepFromHealth: sleepFromHealth,
                weightFromHealth: weightFromHealth,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DailyMetricsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DailyMetricsTable,
      DailyMetricRow,
      $$DailyMetricsTableFilterComposer,
      $$DailyMetricsTableOrderingComposer,
      $$DailyMetricsTableAnnotationComposer,
      $$DailyMetricsTableCreateCompanionBuilder,
      $$DailyMetricsTableUpdateCompanionBuilder,
      (
        DailyMetricRow,
        BaseReferences<_$AppDatabase, $DailyMetricsTable, DailyMetricRow>,
      ),
      DailyMetricRow,
      PrefetchHooks Function()
    >;
typedef $$PhotosTableCreateCompanionBuilder =
    PhotosCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      required String id,
      required DateTime date,
      required PhotoPose pose,
      required String localPath,
      Value<String?> storagePath,
      Value<int?> widthPx,
      Value<int?> heightPx,
      Value<int?> byteSize,
      Value<String?> note,
      Value<int> rowid,
    });
typedef $$PhotosTableUpdateCompanionBuilder =
    PhotosCompanion Function({
      Value<DateTime> updatedAt,
      Value<bool> synced,
      Value<bool> deleted,
      Value<String> id,
      Value<DateTime> date,
      Value<PhotoPose> pose,
      Value<String> localPath,
      Value<String?> storagePath,
      Value<int?> widthPx,
      Value<int?> heightPx,
      Value<int?> byteSize,
      Value<String?> note,
      Value<int> rowid,
    });

class $$PhotosTableFilterComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<PhotoPose, PhotoPose, String> get pose =>
      $composableBuilder(
        column: $table.pose,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get widthPx => $composableBuilder(
    column: $table.widthPx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get heightPx => $composableBuilder(
    column: $table.heightPx,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhotosTableOrderingComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get deleted => $composableBuilder(
    column: $table.deleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get pose => $composableBuilder(
    column: $table.pose,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localPath => $composableBuilder(
    column: $table.localPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get widthPx => $composableBuilder(
    column: $table.widthPx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get heightPx => $composableBuilder(
    column: $table.heightPx,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get byteSize => $composableBuilder(
    column: $table.byteSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhotosTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhotosTable> {
  $$PhotosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);

  GeneratedColumn<bool> get deleted =>
      $composableBuilder(column: $table.deleted, builder: (column) => column);

  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<PhotoPose, String> get pose =>
      $composableBuilder(column: $table.pose, builder: (column) => column);

  GeneratedColumn<String> get localPath =>
      $composableBuilder(column: $table.localPath, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get widthPx =>
      $composableBuilder(column: $table.widthPx, builder: (column) => column);

  GeneratedColumn<int> get heightPx =>
      $composableBuilder(column: $table.heightPx, builder: (column) => column);

  GeneratedColumn<int> get byteSize =>
      $composableBuilder(column: $table.byteSize, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$PhotosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhotosTable,
          PhotoRow,
          $$PhotosTableFilterComposer,
          $$PhotosTableOrderingComposer,
          $$PhotosTableAnnotationComposer,
          $$PhotosTableCreateCompanionBuilder,
          $$PhotosTableUpdateCompanionBuilder,
          (PhotoRow, BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>),
          PhotoRow,
          PrefetchHooks Function()
        > {
  $$PhotosTableTableManager(_$AppDatabase db, $PhotosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhotosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhotosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhotosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                Value<String> id = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<PhotoPose> pose = const Value.absent(),
                Value<String> localPath = const Value.absent(),
                Value<String?> storagePath = const Value.absent(),
                Value<int?> widthPx = const Value.absent(),
                Value<int?> heightPx = const Value.absent(),
                Value<int?> byteSize = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                date: date,
                pose: pose,
                localPath: localPath,
                storagePath: storagePath,
                widthPx: widthPx,
                heightPx: heightPx,
                byteSize: byteSize,
                note: note,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<bool> deleted = const Value.absent(),
                required String id,
                required DateTime date,
                required PhotoPose pose,
                required String localPath,
                Value<String?> storagePath = const Value.absent(),
                Value<int?> widthPx = const Value.absent(),
                Value<int?> heightPx = const Value.absent(),
                Value<int?> byteSize = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhotosCompanion.insert(
                updatedAt: updatedAt,
                synced: synced,
                deleted: deleted,
                id: id,
                date: date,
                pose: pose,
                localPath: localPath,
                storagePath: storagePath,
                widthPx: widthPx,
                heightPx: heightPx,
                byteSize: byteSize,
                note: note,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhotosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhotosTable,
      PhotoRow,
      $$PhotosTableFilterComposer,
      $$PhotosTableOrderingComposer,
      $$PhotosTableAnnotationComposer,
      $$PhotosTableCreateCompanionBuilder,
      $$PhotosTableUpdateCompanionBuilder,
      (PhotoRow, BaseReferences<_$AppDatabase, $PhotosTable, PhotoRow>),
      PhotoRow,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableCreateCompanionBuilder =
    SettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableUpdateCompanionBuilder =
    SettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTable> {
  $$SettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTable,
          SettingRow,
          $$SettingsTableFilterComposer,
          $$SettingsTableOrderingComposer,
          $$SettingsTableAnnotationComposer,
          $$SettingsTableCreateCompanionBuilder,
          $$SettingsTableUpdateCompanionBuilder,
          (
            SettingRow,
            BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>,
          ),
          SettingRow,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableManager(_$AppDatabase db, $SettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTable,
      SettingRow,
      $$SettingsTableFilterComposer,
      $$SettingsTableOrderingComposer,
      $$SettingsTableAnnotationComposer,
      $$SettingsTableCreateCompanionBuilder,
      $$SettingsTableUpdateCompanionBuilder,
      (SettingRow, BaseReferences<_$AppDatabase, $SettingsTable, SettingRow>),
      SettingRow,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$TemplatesTableTableManager get templates =>
      $$TemplatesTableTableManager(_db, _db.templates);
  $$TemplateExercisesTableTableManager get templateExercises =>
      $$TemplateExercisesTableTableManager(_db, _db.templateExercises);
  $$SessionsTableTableManager get sessions =>
      $$SessionsTableTableManager(_db, _db.sessions);
  $$SessionExercisesTableTableManager get sessionExercises =>
      $$SessionExercisesTableTableManager(_db, _db.sessionExercises);
  $$WorkoutSetsTableTableManager get workoutSets =>
      $$WorkoutSetsTableTableManager(_db, _db.workoutSets);
  $$PersonalRecordsTableTableManager get personalRecords =>
      $$PersonalRecordsTableTableManager(_db, _db.personalRecords);
  $$DailyMetricsTableTableManager get dailyMetrics =>
      $$DailyMetricsTableTableManager(_db, _db.dailyMetrics);
  $$PhotosTableTableManager get photos =>
      $$PhotosTableTableManager(_db, _db.photos);
  $$SettingsTableTableManager get settings =>
      $$SettingsTableTableManager(_db, _db.settings);
}
