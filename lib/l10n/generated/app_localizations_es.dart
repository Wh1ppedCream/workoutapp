// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String onboardingBodyWeightPerWeek(String percent) {
    return '$percent % del peso corporal/sem.';
  }

  @override
  String get dashboardExerciseFallback => 'Ejercicio';

  @override
  String dashboardExerciseUsage(String equipment, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces',
      one: '1 vez',
    );
    return '$equipment - $_temp0';
  }

  @override
  String weightCardSetsDone(int completed, int total) {
    return '$completed/$total completadas';
  }

  @override
  String bodyHeatmapSemantics(String bodyPart) {
    return 'Mapa de calor corporal de $bodyPart';
  }

  @override
  String get focusedSetsTitle => 'Series enfocadas';

  @override
  String get bodyPartNeck => 'Cuello';

  @override
  String get bodyPartShoulders => 'Hombros';

  @override
  String get bodyPartChest => 'Pecho';

  @override
  String get bodyPartCore => 'Zona media';

  @override
  String get bodyPartUpperBack => 'Espalda alta';

  @override
  String get bodyPartLowerBack => 'Espalda baja';

  @override
  String get bodyPartBiceps => 'Bíceps';

  @override
  String get bodyPartTriceps => 'Tríceps';

  @override
  String get bodyPartForearms => 'Antebrazos';

  @override
  String get bodyPartHips => 'Caderas';

  @override
  String get bodyPartHamstrings => 'Isquiotibiales';

  @override
  String get bodyPartQuads => 'Cuádriceps';

  @override
  String get bodyPartCalves => 'Pantorrillas';

  @override
  String databaseSaveFile(String filename) {
    return 'Guardar $filename';
  }

  @override
  String databaseFileSaved(String filename) {
    return '$filename se guardó en la ubicación seleccionada.';
  }

  @override
  String databaseProductionEnvironment(String label) {
    return '$label (producción)';
  }

  @override
  String dashboardDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'hace $count días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String get workoutReportRangeOneWeekShort => '1S';

  @override
  String get workoutReportRangeOneMonthShort => '1M';

  @override
  String get workoutReportRangeThreeMonthsShort => '3M';

  @override
  String get workoutReportRangeSixMonthsShort => '6M';

  @override
  String get workoutReportRangeOneYearShort => '1A';

  @override
  String get workoutReportRangeAll => 'Todo';

  @override
  String get workoutReportRangeOneWeek => '1 semana';

  @override
  String get workoutReportRangeOneMonth => '1 mes';

  @override
  String get workoutReportRangeThreeMonths => '3 meses';

  @override
  String get workoutReportRangeSixMonths => '6 meses';

  @override
  String get workoutReportRangeOneYear => '1 año';

  @override
  String workoutReportChartTitle(String metric, String period) {
    return '$metric ($period)';
  }

  @override
  String workoutReportWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrenamientos',
      one: '1 entrenamiento',
      zero: '0 entrenamientos',
    );
    return '$_temp0';
  }

  @override
  String workoutReportMinutesCount(int count) {
    return '$count min';
  }

  @override
  String workoutReportHoursCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String workoutReportHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get workoutReportMinuteShort => 'min';

  @override
  String get workoutReportHourShort => 'h';

  @override
  String get workoutReportNoWorkoutsYet => 'Aún no hay entrenamientos';

  @override
  String get workoutReportNoTrainingTimeYet => 'Aún no hay tiempo de entrenamiento';

  @override
  String get workoutReportNoVolumeYet => 'Aún no hay volumen registrado';

  @override
  String get workoutReportNoWorkoutsBody => 'Completa un entrenamiento para empezar a crear este informe.';

  @override
  String get workoutReportNoTrainingTimeBody => 'Las sesiones finalizadas añadirán minutos aquí automáticamente.';

  @override
  String get workoutReportNoVolumeBody => 'Registra pesos en series completadas para crear tendencias de volumen.';

  @override
  String get appTitle => 'Tonos';

  @override
  String get uiAppearanceTitle => 'UI y apariencia';

  @override
  String get uiAppearanceSubtitle => 'Controla el aspecto de Tonos y el comportamiento de las pestañas inferiores.';

  @override
  String get displaySettingsTitle => 'Pantalla';

  @override
  String get displaySettingsSubtitle => 'Preferencias visuales rápidas.';

  @override
  String get darkModeTitle => 'Modo oscuro';

  @override
  String get darkModeSubtitle => 'Usa el tema oscuro de la aplicación.';

  @override
  String get replayOnboardingTitle => 'Repetir onboarding';

  @override
  String get replayOnboardingSubtitle => 'Activa esto para abrir la configuración de nuevo. Se apaga al terminar.';

  @override
  String get weightUnitsTitle => 'Unidades de peso';

  @override
  String weightUnitsSubtitle(String unit) {
    return 'Mostrar pesos y volumen del entrenamiento en $unit.';
  }

  @override
  String get languageTitle => 'Idioma';

  @override
  String get languageSubtitle => 'Elige el idioma que usa Tonos.';

  @override
  String get systemDefaultLanguage => 'Predeterminado del sistema';

  @override
  String get englishLanguage => 'Inglés';

  @override
  String get canadianFrenchLanguage => 'Francés (Canadá)';

  @override
  String get navigationSettingsTitle => 'Navegación';

  @override
  String get navigationSettingsSubtitle => 'Elige qué pestañas inferiores aparecen y en qué orden.';

  @override
  String get editBottomTabsTitle => 'Editar pestañas inferiores';

  @override
  String get editBottomTabsSubtitle => 'Reordena pestañas activas u oculta las que no usas.';

  @override
  String get displaySettingsTutorialTitle => 'Ajustes de pantalla';

  @override
  String get displaySettingsTutorialBody => 'Controla modo oscuro, idioma, repetir onboarding y cambia entre libras y kilogramos.';

  @override
  String get bottomTabsTutorialTitle => 'Pestañas inferiores';

  @override
  String get bottomTabsTutorialBody => 'Edita qué pestañas inferiores se muestran y el orden en que aparecen.';

  @override
  String get onboardingPageWelcome => 'Bienvenida';

  @override
  String get onboardingPageBasics => 'Básicos';

  @override
  String get onboardingPageFocus => 'Enfoque';

  @override
  String get onboardingPageGymProfile => 'Perfil de gimnasio';

  @override
  String get onboardingPageEquipment => 'Equipo';

  @override
  String get onboardingPageWorkoutPlan => 'Plan de entrenamiento';

  @override
  String get onboardingPagePlanOverview => 'Resumen del plan';

  @override
  String get onboardingPageSummary => 'Resumen';

  @override
  String get onboardingPreviousStepTooltip => 'Paso anterior';

  @override
  String onboardingStepProgress(int current, int total) {
    return 'Paso $current de $total';
  }

  @override
  String get onboardingFinish => 'Finalizar';

  @override
  String get onboardingSkip => 'Omitir';

  @override
  String get onboardingFinishing => 'Finalizando...';

  @override
  String get onboardingFinishSetup => 'Finalizar configuración';

  @override
  String get onboardingNext => 'Siguiente';

  @override
  String get onboardingSkipSetupTitle => '¿Omitir configuración?';

  @override
  String get onboardingSkipSetupBody => 'Puedes ir a la página principal ahora y terminar la configuración más tarde. También puedes volver a abrir el onboarding desde la página de ajustes.';

  @override
  String get onboardingCancel => 'Cancelar';

  @override
  String get onboardingConfirm => 'Aceptar';

  @override
  String onboardingFinishError(String error) {
    return 'No se pudo finalizar la configuración: $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Te damos la bienvenida a Tonos';

  @override
  String get onboardingWelcomeSubtitle => 'Una configuración rápida ayuda a personalizar los entrenamientos, la nutrición y el seguimiento del progreso.';

  @override
  String get onboardingLanguageSelectionTitle => 'Elige tu idioma';

  @override
  String get onboardingLanguageSelectionHelp => 'La configuración se actualiza de inmediato. Puedes cambiar esto más tarde en Ajustes.';

  @override
  String get onboardingTrainFeatureTitle => 'Entrena con contexto';

  @override
  String get onboardingTrainFeatureBody => 'Usa tus preferencias e historial para orientar las sugerencias de entrenamiento.';

  @override
  String get onboardingNutritionFeatureTitle => 'Apoyar objetivos de nutrición';

  @override
  String get onboardingNutritionFeatureBody => 'Define el nivel de orientación nutricional que quieres de la aplicación.';

  @override
  String get onboardingProgressFeatureTitle => 'Seguir el progreso';

  @override
  String get onboardingProgressFeatureBody => 'Mantén tus datos de entrenamiento y nutrición conectados con el tiempo.';

  @override
  String get onboardingBasicsTitle => 'Cuéntanos lo básico';

  @override
  String get onboardingBasicsSubtitle => 'Estos datos son opcionales, pero ayudan con los cálculos futuros.';

  @override
  String get onboardingNameLabel => 'Nombre';

  @override
  String get onboardingNameHint => 'Introduce tu nombre';

  @override
  String get onboardingGenderLabel => 'Género';

  @override
  String get onboardingGenderMale => 'Hombre';

  @override
  String get onboardingGenderFemale => 'Mujer';

  @override
  String get onboardingGenderOther => 'Otro';

  @override
  String get onboardingGenderPreferNotToSay => 'Prefiero no decirlo';

  @override
  String get onboardingDateOfBirthLabel => 'Fecha de nacimiento';

  @override
  String get onboardingSelectDate => 'Seleccionar fecha';

  @override
  String get onboardingHeightLabel => 'Estatura';

  @override
  String get onboardingHeightHint => 'p. ej., 5\'10\" o 178 cm';

  @override
  String get onboardingWorkoutWeightUnits => 'Unidades de peso del entrenamiento';

  @override
  String get onboardingCurrentWeightLabel => 'Peso actual';

  @override
  String get onboardingWeightHintPounds => 'p. ej., 160';

  @override
  String get onboardingWeightHintKilograms => 'p. ej., 72';

  @override
  String get onboardingPounds => 'Libras';

  @override
  String get onboardingKilograms => 'Kilogramos';

  @override
  String get onboardingFocusTitle => '¿Qué debería personalizar Tonos?';

  @override
  String get onboardingFocusSubtitle => 'Elige las áreas que quieres configurar ahora. Puedes cambiarlo más tarde.';

  @override
  String get onboardingNutritionDataTitle => 'Datos de nutrición';

  @override
  String get onboardingNutritionDataPausedBody => 'La configuración de nutrición está en pausa mientras se reconstruye esta área.';

  @override
  String get onboardingLater => 'Más tarde';

  @override
  String get onboardingExerciseDataTitle => 'Datos de ejercicio';

  @override
  String get onboardingExerciseDataBody => 'Configura tu perfil de gimnasio y tus primeros planes de entrenamiento.';

  @override
  String get onboardingGymSpaceTitle => '¿Dónde entrenas?';

  @override
  String get onboardingGymSpaceSubtitle => 'Elige un espacio inicial. Su equipo determinará las sugerencias de ejercicios y los entrenamientos generados.';

  @override
  String get onboardingEquipmentLoadError => 'No se pudo cargar el equipo.';

  @override
  String get onboardingTryAgain => 'Intentar de nuevo';

  @override
  String get onboardingGymCustomTitle => 'Espacio personalizado';

  @override
  String get onboardingGymCustomSubtitle => 'Diseña tu propio perfil eligiendo cada elemento disponible.';

  @override
  String get onboardingGymCustomDefaultName => 'Espacio personalizado';

  @override
  String get onboardingGymSkipTitle => 'Omitir este paso';

  @override
  String get onboardingGymSkipSubtitle => 'Mantén el perfil General y elige tu equipo más tarde.';

  @override
  String get onboardingGymGeneralName => 'General';

  @override
  String get onboardingGymCommercialTitle => 'Gimnasio comercial';

  @override
  String get onboardingGymCommercialSubtitle => 'Empieza con todas las opciones de equipo disponibles y elimina lo que tu gimnasio no tenga.';

  @override
  String get onboardingGymCommercialDefaultName => 'Gimnasio comercial';

  @override
  String get onboardingGymHomeTitle => 'Gimnasio en casa';

  @override
  String get onboardingGymHomeSubtitle => 'Una configuración práctica en casa con pesas libres, bandas, banco y equipo de peso corporal.';

  @override
  String get onboardingGymHomeDefaultName => 'Gimnasio en casa';

  @override
  String get onboardingGymCalisthenicsTitle => 'Calistenia';

  @override
  String get onboardingGymCalisthenicsSubtitle => 'Equipo centrado en peso corporal, incluidas barras, anillas, bandas y accesorios básicos.';

  @override
  String get onboardingGymCalisthenicsDefaultName => 'Calistenia';

  @override
  String get onboardingGymPowerliftingTitle => 'Powerlifting';

  @override
  String get onboardingGymPowerliftingSubtitle => 'Un espacio con barra, discos, rack de potencia y banco.';

  @override
  String get onboardingGymPowerliftingDefaultName => 'Powerlifting';

  @override
  String get onboardingGymFreeWeightsTitle => 'Pesas libres';

  @override
  String get onboardingGymFreeWeightsSubtitle => 'Mancuernas, pesas rusas, discos, un banco y movimientos de peso corporal.';

  @override
  String get onboardingGymFreeWeightsDefaultName => 'Pesas libres';

  @override
  String get onboardingReviewWorkoutSpaceTitle => 'Revisa tu espacio de entrenamiento';

  @override
  String get onboardingReviewWorkoutSpaceSubtitle => 'Cambia el nombre del perfil o ajusta su equipo antes de que Tonos lo cree.';

  @override
  String get onboardingProfileNameLabel => 'Nombre del perfil';

  @override
  String get onboardingIncludedEquipmentTitle => 'Equipo incluido';

  @override
  String get onboardingIncludedEquipmentBody => 'Solo se sugerirán ejercicios compatibles con este equipo cuando el perfil esté activo.';

  @override
  String get onboardingNoEquipmentSelected => 'Aún no se ha seleccionado equipo.';

  @override
  String get onboardingReset => 'Restablecer';

  @override
  String get onboardingEditProfile => 'Editar perfil';

  @override
  String get onboardingEditWorkoutSpaceTitle => 'Editar espacio de entrenamiento';

  @override
  String get onboardingSelectEquipmentError => 'Selecciona al menos una opción de equipo.';

  @override
  String get onboardingWorkoutPlanTitle => 'Configura tu plan de entrenamiento';

  @override
  String get onboardingWorkoutPlanSubtitle => 'Elige cómo debería preparar Tonos tus primeros planes. Siempre puedes añadir, archivar o editar planes más tarde.';

  @override
  String get onboardingManualPlanTitle => 'Crear tus propios planes manualmente';

  @override
  String get onboardingManualPlanSubtitle => 'Empieza con un plan vacío y añade los ejercicios y series tú mismo.';

  @override
  String get onboardingPremadePlanTitle => 'Usar planes de ejercicio prediseñados';

  @override
  String get onboardingPremadePlanSubtitle => 'Explora planes integrados de cuerpo completo, tren superior/inferior, empuje-tirón-piernas y divisiones por parte del cuerpo.';

  @override
  String get onboardingGeneratePlanTitle => 'Generar planes de ejercicio';

  @override
  String get onboardingGeneratePlanSubtitle => 'Responde algunas preguntas de configuración y deja que Tonos genere un plan personalizado para tu perfil.';

  @override
  String get onboardingSkipPlanTitle => 'Omitir este paso';

  @override
  String get onboardingSkipPlanSubtitle => 'Empieza sin añadir planes. Puedes configurarlos desde Entrenamiento más tarde.';

  @override
  String onboardingPlansAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se han añadido $count planes a Planes activos.',
      one: 'Se ha añadido $count plan a Planes activos.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingReviewPlansTitle => 'Revisa tus planes';

  @override
  String get onboardingReviewPlansSubtitle => 'Estos planes se añadieron a tus planes activos. Abre cualquier plan para revisarlo o ajustarlo antes de continuar.';

  @override
  String onboardingPlansReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planes están listos en Planes activos.',
      one: '$count plan está listo en Planes activos.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanOverviewLoadError => 'Aún no se pudo cargar el resumen del plan.';

  @override
  String get onboardingNoAddedPlans => 'No se encontraron planes añadidos. Vuelve para añadir planes u omite este paso.';

  @override
  String get onboardingReadyTitle => 'Todo listo';

  @override
  String get onboardingReadySubtitle => 'Revisa tu configuración y finaliza para entrar a Tonos.';

  @override
  String get onboardingSummaryName => 'Nombre';

  @override
  String get onboardingSummaryGender => 'Género';

  @override
  String get onboardingSummaryDateOfBirth => 'Fecha de nacimiento';

  @override
  String get onboardingSummaryHeight => 'Estatura';

  @override
  String get onboardingSummaryWeight => 'Peso';

  @override
  String get onboardingSummaryWorkoutUnits => 'Unidades de entrenamiento';

  @override
  String get onboardingSummaryIncluded => 'Incluido';

  @override
  String get onboardingSummaryGymProfile => 'Perfil de gimnasio';

  @override
  String get onboardingSummaryEquipment => 'Equipo';

  @override
  String get onboardingSummaryWorkoutPlans => 'Planes de entrenamiento';

  @override
  String get onboardingSummaryProfileSection => 'Perfil';

  @override
  String get onboardingSummaryTrainingSection => 'Configuración de entrenamiento';

  @override
  String get onboardingSummaryNutritionSection => 'Preferencias de nutrición';

  @override
  String get onboardingSummaryDiet => 'Dieta';

  @override
  String get onboardingSummaryProteinPreference => 'Preferencia de proteínas';

  @override
  String get onboardingIncludedNutrition => 'Configuración de nutrición';

  @override
  String get onboardingIncludedExercise => 'Configuración de ejercicio';

  @override
  String get onboardingIncludedBasicOnly => 'Solo perfil básico';

  @override
  String onboardingEquipmentSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count seleccionados',
      one: '$count seleccionado',
    );
    return '$_temp0';
  }

  @override
  String onboardingPlanSummaryAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planes añadidos',
      one: '$count plan añadido',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanSummaryPremade => 'Prediseñado seleccionado';

  @override
  String get onboardingPlanSummaryGenerated => 'Generar seleccionado';

  @override
  String get onboardingPlanSummarySkipped => 'Omitido';

  @override
  String get onboardingPlanSummaryManual => 'Manual seleccionado';

  @override
  String get onboardingPlanSummaryNotSelected => 'No seleccionado';

  @override
  String get onboardingNewPlan => 'Nuevo plan';

  @override
  String onboardingNumberedNewPlan(int number) {
    return 'Nuevo plan $number';
  }

  @override
  String get tabTrain => 'Entrenar';

  @override
  String get tabTrainSecondary => 'Entrenar 2';

  @override
  String get tabCatalog => 'Catálogo';

  @override
  String get tabLogbook => 'Registro';

  @override
  String get tabProgress => 'Progreso';

  @override
  String get tabProfile => 'Perfil';

  @override
  String get tabDashboard => 'Panel';

  @override
  String get tabNutrition => 'Nutrición';

  @override
  String get tabNutritionLog => 'Registro de nutrición';

  @override
  String get tabCombinedHistory => 'Historial combinado';

  @override
  String get tabFormAndPosing => 'Forma y poses';

  @override
  String get profileTitle => 'Perfil';

  @override
  String get profileSubtitle => 'Personaliza Tonos, gestiona valores de entrenamiento y mantén tus datos en buen estado.';

  @override
  String get profileAccountSectionTitle => 'Cuenta';

  @override
  String get profileAccountSectionSubtitle => 'Tu identidad y apariencia de la aplicación.';

  @override
  String get profileUserInformationTitle => 'Información de usuario';

  @override
  String get profileUserInformationSubtitle => 'Nombre, detalles corporales y perfil de actividad.';

  @override
  String get profileUiAppearanceTitle => 'UI y apariencia';

  @override
  String get profileUiAppearanceSubtitle => 'Tema, onboarding y configuración de pestañas inferiores.';

  @override
  String get profileGuidedTutorialsTitle => 'Tutoriales guiados';

  @override
  String get profileGuidedTutorialsSubtitle => 'Reproduce recorridos y restablece la ayuda guiada.';

  @override
  String get profileTrainingSectionTitle => 'Entrenamiento';

  @override
  String get profileTrainingSectionSubtitle => 'Valores predeterminados de ejercicios y controles relacionados con el progreso.';

  @override
  String get profileGymWorkoutSettingsTitle => 'Ajustes de gimnasio y entrenamiento';

  @override
  String get profileGymWorkoutSettingsSubtitle => 'Generación de entrenamientos, clasificaciones, flujos y lógica de equipo.';

  @override
  String get profileProgressSettingsTitle => 'Ajustes de progreso';

  @override
  String get profileProgressSettingsSubtitle => 'Configuración de seguimiento de mediciones y tendencias.';

  @override
  String get profileDataSectionTitle => 'Datos';

  @override
  String get profileDataSectionSubtitle => 'Herramientas de base de datos, exportaciones, importaciones y mantenimiento.';

  @override
  String get profileDatabaseSettingsTitle => 'Ajustes de base de datos';

  @override
  String get profileDatabaseSettingsSubtitle => 'Importación, exportación, comprobaciones de estado y herramientas de mantenimiento.';

  @override
  String get profileNutritionSectionTitle => 'Nutrición';

  @override
  String get profileNutritionSectionSubtitle => 'Los ajustes de nutrición están pausados mientras se reconstruye esta área.';

  @override
  String get profileDietNutritionSettingsTitle => 'Ajustes de dieta y nutrición';

  @override
  String get profileDietNutritionSettingsSubtitle => 'Los objetivos y preferencias de nutrición volverán más tarde.';

  @override
  String get profileLater => 'Más tarde';

  @override
  String get profileAccountTutorialTitle => 'Ajustes de cuenta';

  @override
  String get profileAccountTutorialBody => 'Actualiza aquí tu información personal, preferencias de pantalla, unidades de peso, onboarding, pestañas inferiores y tutoriales guiados.';

  @override
  String get profileTrainingTutorialTitle => 'Ajustes de entrenamiento';

  @override
  String get profileTrainingTutorialBody => 'Controla perfiles de gimnasio, reglas de generación, clasificaciones corporales, ajustes de progreso y otros valores de entrenamiento.';

  @override
  String get profileDataTutorialTitle => 'Herramientas de datos';

  @override
  String get profileDataTutorialBody => 'En los ajustes de base de datos exportas, importas, compruebas y mantienes tus datos de entrenamiento locales.';

  @override
  String catalogLoadError(String error) {
    return 'No se pudo cargar el catálogo: $error';
  }

  @override
  String get catalogNoData => 'Aún no hay datos de catálogo disponibles.';

  @override
  String get catalogExerciseTitle => 'Catálogo de ejercicios';

  @override
  String get catalogMostUsedExercises => 'Ejercicios más usados';

  @override
  String get catalogNoExerciseHistory => 'Completa entrenamientos para ver aquí tus ejercicios más frecuentes.';

  @override
  String get catalogTargetAnatomyTitle => 'Anatomía objetivo';

  @override
  String get catalogBodyparts => 'Partes del cuerpo';

  @override
  String get catalogMuscles => 'Músculos';

  @override
  String get catalogNoBodypartHistory => 'Aún no hay historial de partes corporales.';

  @override
  String get catalogNoMuscleHistory => 'Aún no hay historial muscular.';

  @override
  String get catalogExerciseTutorialTitle => 'Catálogo de ejercicios';

  @override
  String get catalogExerciseTutorialBody => 'Tus ejercicios más usados aparecen primero. Toca la tarjeta para abrir el catálogo completo, buscar movimientos y revisar detalles.';

  @override
  String get catalogAnatomyTutorialTitle => 'Anatomía objetivo';

  @override
  String get catalogAnatomyTutorialBody => 'Resume las partes corporales y músculos que más has entrenado. Toca cualquier lado para abrir la biblioteca de anatomía con listas enfocadas.';

  @override
  String catalogTimesUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count veces',
      one: '1 vez',
    );
    return '$_temp0';
  }

  @override
  String catalogSetUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 serie',
    );
    return '$_temp0';
  }

  @override
  String get navEditorMinimumTabsError => 'Mantén al menos dos pestañas activas.';

  @override
  String get navEditorSavedMessage => 'Pestañas inferiores guardadas';

  @override
  String get navEditorTitle => 'Editar pestañas inferiores';

  @override
  String get navEditorSubtitle => 'Elige qué aparece en la barra inferior y reordena las pestañas activas.';

  @override
  String get navEditorSave => 'Guardar pestañas';

  @override
  String get navEditorActiveTitle => 'Pestañas activas';

  @override
  String get navEditorActiveSubtitle => 'Arrastra para reordenar. El perfil sigue disponible.';

  @override
  String get navEditorInactiveTitle => 'Pestañas inactivas';

  @override
  String get navEditorInactiveSubtitle => 'Actívalas de nuevo cuando quieras.';

  @override
  String get navEditorNoInactiveTabs => 'No hay pestañas inactivas.';

  @override
  String get navEditorAlwaysShown => 'Siempre visible';

  @override
  String get navEditorVisible => 'Visible en la navegación inferior';

  @override
  String get navEditorHidden => 'Oculta de la navegación inferior';

  @override
  String get trainTutorialSpacesTitle => 'Entrenamiento tiene dos espacios';

  @override
  String get trainTutorialSpacesBody => 'El resumen mantiene al frente los controles de entrenamiento listos. En Planes puedes explorar, generar y gestionar los planes guardados.';

  @override
  String get trainTutorialWeeklyTitle => 'Resumen semanal';

  @override
  String get trainTutorialWeeklyBody => 'Esto muestra las partes corporales entrenadas recientemente. Toca la lista de series enfocadas para abrir el desglose semanal completo.';

  @override
  String get trainTutorialActivePlansTitle => 'Planes activos';

  @override
  String get trainTutorialActivePlansBody => 'Los planes activos son las rutinas que quieres tener cerca. Usa el lápiz para elegir qué planes quedan listos en el resumen.';

  @override
  String get trainTutorialStartTitle => 'Iniciar u optimizar';

  @override
  String get trainTutorialStartBody => 'Iniciar entrenamiento comienza una sesión vacía. Optimizar crea una sesión usando tu historial, equipo del perfil, enfoque y reglas de recuperación.';

  @override
  String get trainTutorialProfilesTitle => 'Perfiles de gimnasio';

  @override
  String get trainTutorialProfilesBody => 'Cambia perfiles al entrenar en otro lugar para que los entrenamientos generados y cambios solo usen equipo disponible.';

  @override
  String get trainSelectProfileFirst => 'Selecciona primero un perfil de gimnasio.';

  @override
  String trainGeneratedPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se generaron $count planes.',
      one: 'Se generó 1 plan.',
    );
    return '$_temp0';
  }

  @override
  String trainNewPlanName(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Nuevo plan $number',
      one: 'Nuevo plan',
    );
    return '$_temp0';
  }

  @override
  String trainOptimizedWorkoutName(String date, String time) {
    return 'Entrenamiento optimizado $date $time';
  }

  @override
  String get trainRestTitle => 'Tómate tiempo para descansar';

  @override
  String get trainRestBody => 'Tu entrenamiento reciente ya está en varios límites de partes corporales, por lo que un entrenamiento optimizado exigiría demasiado a la recuperación.';

  @override
  String get commonOkay => 'Aceptar';

  @override
  String get trainNoEligibleExercises => 'No se encontraron ejercicios adecuados para este perfil.';

  @override
  String get trainAnotherWorkoutActive => 'Ya hay otro entrenamiento activo, por lo que se mantuvo sin cambios.';

  @override
  String trainOptimizedStartFailed(String error) {
    return 'No se pudo iniciar el entrenamiento optimizado: $error';
  }

  @override
  String trainOptimizedManualWeights(int count) {
    return 'Se inició un entrenamiento optimizado. $count ejercicio(s) aún necesitan pesos manuales.';
  }

  @override
  String trainOptimizedStarterWeights(int count) {
    return 'Se inició un entrenamiento optimizado con pesos iniciales para $count ejercicio(s) nuevo(s).';
  }

  @override
  String get trainGymProfilesTooltip => 'Perfiles de gimnasio';

  @override
  String get trainOverviewTab => 'Resumen';

  @override
  String get trainPlansTab => 'Planes';

  @override
  String get trainActivePlans => 'Planes activos';

  @override
  String get trainEditActivePlans => 'Editar planes activos';

  @override
  String get trainSelectProfileForPlans => 'Selecciona un perfil de gimnasio para elegir planes activos.';

  @override
  String get trainChooseActivePlans => 'Toca el lápiz para elegir qué planes se muestran aquí.';

  @override
  String get trainSelectedPlansMissing => 'Los planes seleccionados ya no están disponibles. Toca el lápiz para actualizarlos.';

  @override
  String get trainArchivedPlans => 'Planes archivados';

  @override
  String get trainNoActivePlans => 'Aún no hay planes activos. Usa el lápiz de la tarjeta Planes activos del resumen para elegir los que estarán listos.';

  @override
  String get trainNoArchivedPlans => 'No hay planes archivados.';

  @override
  String get trainManagePlans => 'Gestionar planes';

  @override
  String get trainPremadePlans => 'Planes prediseñados';

  @override
  String trainPremadeDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Hay $count rutinas seleccionadas disponibles para copiar en tus planes.',
      one: 'Hay 1 rutina seleccionada disponible para copiar en tus planes.',
    );
    return '$_temp0';
  }

  @override
  String get trainBrowsePremadePlans => 'Explorar planes prediseñados';

  @override
  String get trainGenerateCustomPlans => 'Generar planes personalizados';

  @override
  String get trainManuallyAddPlan => 'Añadir plan manualmente';

  @override
  String get trainStartWorkout => 'Iniciar entrenamiento';

  @override
  String get trainOptimize => 'Optimizar';

  @override
  String get trainOptimizedSettings => 'Ajustes de entrenamiento optimizado';

  @override
  String planManagementDefaultName(int id) {
    return 'Plan $id';
  }

  @override
  String get planManagementActiveTutorialTitle => 'Planes activos';

  @override
  String get planManagementActiveTutorialBody => 'Estos planes permanecen visibles en el resumen de Entrenamiento. Usa Archivar cuando quieras ocultar uno sin eliminarlo.';

  @override
  String get planManagementArchivedTutorialTitle => 'Planes archivados';

  @override
  String get planManagementArchivedTutorialBody => 'Los planes archivados siguen guardados. Activa cualquier plan aquí cuando quieras devolverlo al resumen.';

  @override
  String planManagementUpdateFailed(String plan, String error) {
    return 'No se pudo actualizar $plan: $error';
  }

  @override
  String get planManagementTitle => 'Gestionar planes';

  @override
  String get planManagementLoadFailed => 'No se pudieron cargar los planes';

  @override
  String get commonTryAgain => 'Intentar de nuevo';

  @override
  String get planManagementIntro => 'Elige qué permanece listo en tu resumen de Entrenamiento. Los planes archivados se guardan y se pueden activar en cualquier momento.';

  @override
  String get planManagementActiveSubtitle => 'Se muestra en el resumen de Entrenamiento.';

  @override
  String get planManagementNoActive => 'Aún no hay planes activos. Activa un plan abajo para fijarlo al resumen.';

  @override
  String get planManagementArchive => 'Archivar';

  @override
  String get planManagementArchivedSubtitle => 'Planes guardados que no aparecen en el resumen.';

  @override
  String get planManagementNoArchived => 'No hay planes archivados.';

  @override
  String get planManagementActivate => 'Activar';

  @override
  String get planManagementAutomatic => 'Plan automático';

  @override
  String get planManagementVisible => 'Visible en el resumen';

  @override
  String get planManagementHidden => 'Oculto del resumen';

  @override
  String get presetsNoPlans => 'No se encontraron planes.';

  @override
  String get presetsNoProfile => 'No se seleccionó ningún perfil.';

  @override
  String get presetsLoadError => 'Error al cargar planes';

  @override
  String presetsShowMore(int count) {
    return 'Mostrar $count más';
  }

  @override
  String presetsShowMoreRemaining(int count, int remaining) {
    return 'Mostrar $count más ($remaining restantes)';
  }

  @override
  String planDefaultName(int number) {
    return 'Plan $number';
  }

  @override
  String get planArchive => 'Archivar';

  @override
  String get planActivate => 'Activar';

  @override
  String get commonDelete => 'Eliminar';

  @override
  String get commonRename => 'Renombrar';

  @override
  String get planActivated => 'Plan activado.';

  @override
  String get planArchived => 'Plan archivado.';

  @override
  String get planDeleteTitle => 'Eliminar preajuste';

  @override
  String get planDeleteConfirmation => '¿Seguro que quieres eliminar este plan?';

  @override
  String get commonCancel => 'Cancelar';

  @override
  String get planRenameTitle => 'Renombrar plan';

  @override
  String get planNameLabel => 'Nombre del plan';

  @override
  String get optimizedTutorialBudgetTitle => 'Presupuesto de sesión';

  @override
  String get optimizedTutorialBudgetBody => 'Define cuánto debe durar el entrenamiento optimizado y cuántas series puede recibir cada ejercicio.';

  @override
  String get optimizedTutorialRepsTitle => 'Repeticiones y peso';

  @override
  String get optimizedTutorialRepsBody => 'Estas opciones controlan el patrón de series, las repeticiones objetivo y cuán conservadores deben ser los pesos generados.';

  @override
  String get optimizedTutorialFocusTitle => 'Enfoque por parte corporal';

  @override
  String get optimizedTutorialFocusBody => 'Prefiere o evita partes del cuerpo para el próximo entrenamiento optimizado sin cambiar tus clasificaciones guardadas.';

  @override
  String get commonReset => 'Restablecer';

  @override
  String get optimizedTutorialResetBody => 'Restablecer devuelve esta página a los valores predeterminados de Tonos si la configuración actual no se siente adecuada.';

  @override
  String get optimizedTutorialActionsTitle => 'Guardar o comenzar';

  @override
  String get optimizedTutorialActionsBody => 'Comenzar ahora usa los valores actuales en pantalla una vez. Guardar conserva la configuración para futuros entrenamientos optimizados.';

  @override
  String optimizedValidationError(int maxSets) {
    return 'Introduce una duración, objetivo de repeticiones y rango de series válidos entre 1 y $maxSets.';
  }

  @override
  String get optimizedBudgetDescription => 'Se usó un presupuesto de 3 minutos por serie más 5 minutos para iniciar cada ejercicio.';

  @override
  String get optimizedWorkoutDuration => 'Duración del entrenamiento';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get optimizedMinimumSets => 'Mínimo de series por ejercicio';

  @override
  String get optimizedMaximumSets => 'Máximo de series por ejercicio';

  @override
  String get unitSets => 'series';

  @override
  String get optimizedRepsWeightsTitle => 'Repeticiones y pesos';

  @override
  String get optimizedRepsWeightsDescription => 'Usa estimaciones de fuerza basadas en el historial cuando están disponibles; Fácil y Medio reducen más que Difícil. Los ejercicios nuevos usan estimaciones iniciales conservadoras.';

  @override
  String get optimizedRepPattern => 'Patrón de repeticiones';

  @override
  String get repModeMixed => 'Mixto';

  @override
  String get repModePyramid => 'Pirámide';

  @override
  String get repModeConsistent => 'Constante';

  @override
  String get optimizedTargetReps => 'Repeticiones objetivo';

  @override
  String get unitReps => 'reps';

  @override
  String get optimizedWeightIntensity => 'Intensidad de peso';

  @override
  String get intensityEasy => 'Fácil';

  @override
  String get intensityMedium => 'Medio';

  @override
  String get intensityHard => 'Difícil';

  @override
  String get optimizedBodypartFocusTitle => 'Enfoque por parte corporal';

  @override
  String get optimizedBodypartFocusDescription => 'Estas selecciones solo se aplican al próximo entrenamiento optimizado que inicies. Toca una vez para preferir, dos veces para evitar y otra vez para borrar.';

  @override
  String get optimizedBodypartsUnavailable => 'No se pudieron cargar las partes del cuerpo.';

  @override
  String get commonStartNow => 'Comenzar ahora';

  @override
  String get commonSave => 'Guardar';

  @override
  String get generateTutorialIntroTitle => 'Crear planes';

  @override
  String get generateTutorialIntroBody => 'Esta página puede crear un plan o un conjunto semanal equilibrado usando tu perfil de gimnasio y preferencias de entrenamiento.';

  @override
  String get generateWorkoutSetupTitle => 'Configuración de entrenamiento';

  @override
  String get generateTutorialSetupBody => 'Define la duración de sesión, cuántos planes crear y el máximo de series permitido para cada ejercicio.';

  @override
  String get generateTrainingFocusTitle => 'Enfoque de entrenamiento';

  @override
  String get generateTutorialFocusBody => 'Prefiere o evita partes corporales aquí. El historial de 7 días solo influye en la generación cuando quieres considerar el entrenamiento reciente.';

  @override
  String get generateRepsWeightsTitle => 'Repeticiones y pesos';

  @override
  String get generateTutorialRepsBody => 'Elige patrones de series pirámide, mixto o constante, además de repeticiones objetivo e intensidad de peso inicial.';

  @override
  String get generateSetAllocationTitle => 'Asignación de series';

  @override
  String get generateTutorialAllocationBody => 'Elige si las series se distribuyen uniformemente o se orientan a tus clasificaciones de partes corporales o músculos.';

  @override
  String get generateTutorialGenerateTitle => 'Generar';

  @override
  String get generateTutorialGenerateBody => 'Cuando todo parezca correcto, genera el plan o conjunto de planes. Los planes nuevos se pueden revisar y editar después.';

  @override
  String get generateValidationError => 'Introduce duración, número de planes, límite de series y valores de repeticiones válidos.';

  @override
  String get generateNoViablePlans => 'No se pudieron generar planes viables con los ajustes actuales.';

  @override
  String generateFailed(String error) {
    return 'No se pudieron generar los planes: $error';
  }

  @override
  String generateDiscardFailed(String error) {
    return 'No se pudieron descartar los planes generados: $error';
  }

  @override
  String get generateIntroTitle => 'Crea tu semana de planes';

  @override
  String get generateIntroBody => 'Crea un plan o un conjunto equilibrado usando tu perfil, enfoque y límites.';

  @override
  String generatePlanCountPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count planes',
      one: '1 plan',
    );
    return '$_temp0';
  }

  @override
  String generateDurationPill(String minutes) {
    return '$minutes min';
  }

  @override
  String generateMaxSetsPill(String sets) {
    return 'máx. $sets series';
  }

  @override
  String generateSetupSummary(String plans, String minutes, String sets) {
    return '$plans plan(es), $minutes min, $sets series máximas';
  }

  @override
  String get generateSessionLength => 'Duración de sesión';

  @override
  String get generateSessionLengthHelp => 'Estimado como 3 min/serie + 5 min/ejercicio.';

  @override
  String get generatePlansToCreate => 'Planes que crear';

  @override
  String generatePlansToCreateHelp(int maxPlans) {
    return 'Normalmente coincide con los días de entrenamiento por semana. Máximo: $maxPlans.';
  }

  @override
  String get unitPlans => 'planes';

  @override
  String get generateMaxSetsPerExercise => 'Máximo de series por ejercicio';

  @override
  String generateSetLimitHelp(int minSets, int maxSets) {
    return 'Se permiten $minSets-$maxSets series.';
  }

  @override
  String generateFocusSummary(int preferred, int avoided, String history) {
    return '$preferred preferidas, $avoided evitadas, historial de 7 días: $history';
  }

  @override
  String get generateHistoryUsing => 'usando';

  @override
  String get generateHistoryNotUsing => 'sin usar';

  @override
  String get generateUseRecentTraining => 'Usar entrenamiento reciente';

  @override
  String get generateUseRecentTrainingBody => 'Da preferencia a áreas poco entrenadas durante los últimos 7 días.';

  @override
  String get generateBodypartFocusInstruction => 'Toca una vez para preferir, dos para evitar y una tercera para borrar.';

  @override
  String generateRepsSummary(String mode, String reps, String intensity) {
    return '$mode, $reps repeticiones, intensidad $intensity';
  }

  @override
  String get generateMixedBody => 'Pirámide para 3+ series; constante para trabajos más cortos.';

  @override
  String get generatePyramidBody => 'La serie máxima usa el peso de trabajo generado.';

  @override
  String get generateConsistentBody => 'Mismas repeticiones y peso sugerido en cada serie.';

  @override
  String get generateTargetRepsHelp => 'Repeticiones máximas para pirámide; repeticiones constantes en caso contrario.';

  @override
  String get generateEasyBody => 'Recomendación de historial o inicial más conservadora.';

  @override
  String get generateMediumBody => 'Recomendación equilibrada de peso de trabajo.';

  @override
  String get generateHardBody => 'Recomendación más pesada, aún redondeada y consciente del esfuerzo.';

  @override
  String get generateRequirementBodyparts => 'Clasificaciones de partes corporales';

  @override
  String get generateRequirementMuscles => 'Clasificaciones musculares';

  @override
  String get generateRequirementEven => 'Cobertura uniforme';

  @override
  String get generateEvenCoverageTitle => 'Cobertura corporal uniforme';

  @override
  String get generateEvenCoverageBody => 'Distribuye el trabajo entre las partes corporales disponibles.';

  @override
  String get generateBodypartRankingsTitle => 'Usar clasificaciones de partes corporales';

  @override
  String get generateBodypartRankingsBody => 'Da más trabajo planificado a las partes corporales mejor clasificadas.';

  @override
  String get generateRankBodyparts => 'Clasificar partes corporales';

  @override
  String get generateMuscleRankingsTitle => 'Usar clasificaciones musculares';

  @override
  String get generateMuscleRankingsBody => 'Asigna trabajo según tus prioridades musculares clasificadas.';

  @override
  String get generateRankMuscles => 'Clasificar músculos';

  @override
  String get generateGenerating => 'Generando...';

  @override
  String generateButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Generar $count planes',
      one: 'Generar plan',
    );
    return '$_temp0';
  }

  @override
  String generatePartialMessage(int generated, int requested) {
    return 'Se generaron $generated de $requested planes. Los ajustes actuales limitaron el resto.';
  }

  @override
  String generateSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Se generaron $count planes. Revísalos cuando estés listo.',
      one: 'Plan generado añadido. Revísalo cuando estés listo.',
    );
    return '$_temp0';
  }

  @override
  String generateMoreNames(int count) {
    return '$count más';
  }

  @override
  String get generateStarterEstimatedBody => 'Se estimaron pesos iniciales para ejercicios nuevos. Ajústalos según sea necesario después de tu primera serie.';

  @override
  String get generateStarterUnavailableBody => 'Algunos ejercicios aún necesitan pesos manuales porque no hay una estimación inicial segura disponible.';

  @override
  String get generateStarterDialogTitle => 'Pesos iniciales añadidos';

  @override
  String get generatePageTitle => 'Generar planes';

  @override
  String get generateDiscarding => 'Descartando...';

  @override
  String get generateReviewPlans => 'Revisar planes';

  @override
  String get sessionTutorialCardsTitle => 'Tarjetas de ejercicios';

  @override
  String get sessionTutorialCardsBody => 'Cada tarjeta contiene un ejercicio. Ábrela para editar pesos y repeticiones, y marca las series al completarlas.';

  @override
  String get sessionTutorialAddTitle => 'Añadir ejercicios';

  @override
  String get sessionTutorialAddBody => 'Usa este botón cuando quieras añadir otro ejercicio desde el catálogo durante el entrenamiento.';

  @override
  String get sessionTutorialFinishTitle => 'Finalizar entrenamiento';

  @override
  String get sessionTutorialFinishBody => 'Cuando termines, finaliza la sesión para que Tonos guarde el entrenamiento y actualice tu historial, análisis y widgets de progreso.';

  @override
  String get sessionTimerTitle => 'Temporizador de entrenamiento';

  @override
  String get sessionTitle => 'Sesión de entrenamiento';

  @override
  String get sessionNoExercises => 'No se añadieron ejercicios.';

  @override
  String get sessionNeedCompletedSet => 'Completa al menos una serie antes de finalizar el entrenamiento.';

  @override
  String sessionSaveFailed(String error) {
    return 'No se pudo guardar el entrenamiento. Tu entrenamiento en curso sigue disponible. $error';
  }

  @override
  String get sessionFinishWorkout => 'Finalizar entrenamiento';

  @override
  String get sessionResume => 'Reanudar';

  @override
  String get sessionExit => 'Salir';

  @override
  String get sessionCompletedSaved => 'Trabajo completado guardado en el Registro.';

  @override
  String get sessionCancelled => 'Entrenamiento cancelado.';

  @override
  String sessionEndFailed(String error) {
    return 'No se pudo terminar el entrenamiento: $error';
  }

  @override
  String get sessionCancelQuestion => '¿Cancelar entrenamiento?';

  @override
  String get sessionCancelBody => 'Esto elimina el entrenamiento en curso sin añadirlo a tu historial.';

  @override
  String get sessionKeepWorkout => 'Mantener entrenamiento';

  @override
  String get sessionCancelWorkout => 'Cancelar entrenamiento';

  @override
  String get sessionEndQuestion => '¿Terminar entrenamiento?';

  @override
  String get sessionCancelDelete => 'Cancelar y eliminar';

  @override
  String get sessionEndSave => 'Terminar y guardar entrenamiento';

  @override
  String get sessionRememberChoice => 'Recordar elección';

  @override
  String get sessionRememberChoiceBody => 'Cambia esto más tarde en Ajustes de gimnasio y entrenamiento.';

  @override
  String get sessionCompleteLoadError => 'Error al cargar sesión';

  @override
  String get sessionCompleteTitle => 'ENTRENAMIENTO COMPLETADO';

  @override
  String get sessionMetricExercises => 'Ejercicios';

  @override
  String get sessionMetricSets => 'Series';

  @override
  String get sessionMetricDuration => 'Duración';

  @override
  String get sessionMetricVolume => 'Volumen';

  @override
  String get commonDone => 'Listo';

  @override
  String get recordMonthly => 'Mensual';

  @override
  String get recordAllTime => 'Todo el tiempo';

  @override
  String get recordFirst => 'Primer récord';

  @override
  String recordRepBest(int reps) {
    return 'Mejor de $reps repeticiones';
  }

  @override
  String get recordVolumeBest => 'Mejor volumen';

  @override
  String sessionEstimatedMax(String weight) {
    return 'ERM=$weight';
  }

  @override
  String durationMinutesCompact(int minutes) {
    return '${minutes}m';
  }

  @override
  String durationHoursCompact(int hours) {
    return '${hours}h';
  }

  @override
  String durationHoursMinutesCompact(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String get planUnsavedChangesTitle => 'Cambios sin guardar';

  @override
  String get planDiscardChangesQuestion => '¿Descartar cambios?';

  @override
  String get planDiscard => 'Descartar';

  @override
  String get planTutorialEditTitle => 'Editar plan';

  @override
  String get planTutorialEditBody => 'Úsalo para renombrar el plan, reordenar ejercicios, añadir ejercicios, cambiar movimientos y modificar series.';

  @override
  String get planTutorialSummaryTitle => 'Resumen del plan';

  @override
  String get planTutorialSummaryBody => 'Muestra el tiempo estimado, volumen y las principales partes del cuerpo a las que apunta este plan antes de iniciarlo.';

  @override
  String get planTutorialExerciseCardsTitle => 'Tarjetas de ejercicios';

  @override
  String get planTutorialExerciseCardsBody => 'Abre las tarjetas de ejercicios para revisar las series planificadas. En modo de edición, usa el menú para cambiar o quitar ejercicios.';

  @override
  String get planTutorialStartOrSaveTitle => 'Iniciar o guardar';

  @override
  String get planTutorialStartOrSaveBody => 'Iniciar sesión comienza este plan como entrenamiento. En modo de edición, cambia a Guardar preajuste para almacenar tus cambios.';

  @override
  String get planGuideNameTitle => 'Nombra tu plan';

  @override
  String get planGuideNameBody => 'Pon a este plan un nombre que reconozcas, como Tren superior o Día 1.';

  @override
  String get commonContinue => 'Continuar';

  @override
  String get planGuideBrowseTitle => 'Explorar ejercicios';

  @override
  String get planGuideBrowseBody => 'Toca el botón + para elegir el primer ejercicio de este plan.';

  @override
  String get planGuideWeightTitle => 'Elige un peso';

  @override
  String get planGuideWeightBody => 'Introduce un peso inicial para la primera serie. Usa 0 para un ejercicio de peso corporal.';

  @override
  String get planGuideWeightSet => 'Peso configurado';

  @override
  String get planGuideRepsTitle => 'Elige tus repeticiones';

  @override
  String get planGuideRepsBody => 'Introduce cuántas repeticiones planeas realizar para esta serie.';

  @override
  String get planGuideRepsSet => 'Repeticiones configuradas';

  @override
  String get planGuideAddSetTitle => 'Añadir más series';

  @override
  String get planGuideAddSetBody => 'Usa Añadir serie cuando necesites otra serie. Las nuevas series comienzan con los valores de la serie anterior.';

  @override
  String get planGuideSaveTitle => 'Guarda tu plan';

  @override
  String get planGuideSaveBody => 'Toca Guardar preajuste para conservar este plan y volver al resumen del onboarding.';

  @override
  String planSaveFailed(String error) {
    return 'No se pudo guardar el plan. La versión anterior no ha cambiado. $error';
  }

  @override
  String get planOngoingWorkoutKept => 'Se mantuvo tu entrenamiento en curso. Termínalo o cancélalo antes de iniciar este plan.';

  @override
  String get planDeleteBody => '¿Seguro que quieres eliminar este preajuste?';

  @override
  String get planDeletePreset => 'Eliminar preajuste';

  @override
  String get planDisableAutomatic => 'Desactivar automático';

  @override
  String get planMakeAutomatic => 'Hacer automático';

  @override
  String get planAutomaticSettings => 'Ajustes automáticos';

  @override
  String get planProgression => 'Progresión del plan';

  @override
  String get planNoExercises => 'No hay ejercicios en este preajuste.';

  @override
  String get planSavePreset => 'Guardar preajuste';

  @override
  String get planStartSession => 'Iniciar sesión';

  @override
  String get commonName => 'Nombre';

  @override
  String get commonBack => 'Atrás';

  @override
  String get flowMethodWeight => 'Peso';

  @override
  String get flowMethodReps => 'Repeticiones';

  @override
  String get flowMethodAddSet => 'Añadir serie';

  @override
  String get flowMethodDeleteSet => 'Eliminar serie';

  @override
  String get flowAppDefaultTitle => 'Progresión predeterminada de la aplicación';

  @override
  String get flowProfileDefaultTitle => 'Progresión predeterminada del gimnasio';

  @override
  String get flowPlanSubtitle => 'Define cómo progresa este plan después de cada entrenamiento.';

  @override
  String get flowAppDefaultSubtitle => 'Define el flujo de progresión inicial para nuevos perfiles de gimnasio.';

  @override
  String flowProfileDefaultSubtitle(String profileName) {
    return 'Define el flujo de progresión inicial para nuevos planes en $profileName.';
  }

  @override
  String get flowThisGymProfile => 'este perfil de gimnasio';

  @override
  String get flowManageMethods => 'Gestionar acciones';

  @override
  String get flowAddNewMethod => 'Añadir nueva acción';

  @override
  String get flowNewMethod => 'Nueva acción';

  @override
  String get flowFactor => 'Factor';

  @override
  String get flowAmount => 'Cantidad';

  @override
  String get flowExplicit => 'Explícito';

  @override
  String get flowCopyFromSet => 'Copiar de la serie';

  @override
  String get flowWeight => 'Peso';

  @override
  String get flowReps => 'Repeticiones';

  @override
  String get flowSetIndex => 'Índice de serie (-1 = última)';

  @override
  String get flowDeleteLastSetBody => 'Esta acción eliminará la última serie.';

  @override
  String get flowMethodNameRequired => 'El nombre de la acción no puede estar vacío';

  @override
  String get flowManageActionsTooltip => 'Gestionar acciones de progresión';

  @override
  String get flowAddBranchTitle => 'Añadir una rama';

  @override
  String get flowAddBranchSubtitle => 'Elige a dónde debe llevar el próximo éxito o fallo.';

  @override
  String get flowBranchFrom => 'Ramificar desde';

  @override
  String get flowSuccess => 'Éxito';

  @override
  String get flowMiss => 'Fallo';

  @override
  String get flowAttachActionTitle => 'Adjuntar una acción de progresión';

  @override
  String get flowAttachActionSubtitle => 'Aplica un ajuste de cada tipo a un nodo de flujo.';

  @override
  String get flowApplyActionTo => 'Aplicar acción a';

  @override
  String get flowProgressionAction => 'Acción de progresión';

  @override
  String get flowAddAction => '+ Acción';

  @override
  String get flowRemoveAction => '- Acción';

  @override
  String get flowRemoveNode => '- Nodo';

  @override
  String get commonEdit => 'Editar';

  @override
  String get rulesEditAppDefault => 'Editar regla predeterminada de aplicación';

  @override
  String get rulesEditProfileDefault => 'Editar regla predeterminada de perfil';

  @override
  String get rulesAddAppDefault => 'Añadir regla predeterminada de aplicación';

  @override
  String get rulesAddProfileDefault => 'Añadir regla predeterminada de perfil';

  @override
  String get rulesCopy => 'Copiar';

  @override
  String get rulesCopyIndex => 'Índice de copia';

  @override
  String get rulesDeleteLastSetBody => 'Esto eliminará la última serie.';

  @override
  String get rulesNameRequired => 'El nombre de la regla no puede estar vacío';

  @override
  String get rulesProfilesLowercase => 'perfiles';

  @override
  String get rulesPlansLowercase => 'planes';

  @override
  String rulesAddToExistingTitle(String destination) {
    return '¿Añadir a $destination existentes?';
  }

  @override
  String rulesAddToExistingBody(String name, int count, String destination) {
    return '¿Hacer \"$name\" disponible en $count $destination existentes? Las reglas existentes con el mismo nombre y todos los flujos guardados no cambiarán.';
  }

  @override
  String get rulesNotNow => 'Ahora no';

  @override
  String rulesAddTo(String destination) {
    return 'Añadir a $destination';
  }

  @override
  String rulesNoExistingNeeded(String destination) {
    return 'Ningún $destination existente necesita esta regla.';
  }

  @override
  String rulesCopiedMessage(String name, int count, String destination) {
    return 'Se añadió \"$name\" a $count $destination.';
  }

  @override
  String get rulesPropagationFailed => 'No se pudo añadir la regla a los elementos existentes.';

  @override
  String get rulesOptionsTooltip => 'Opciones de regla';

  @override
  String get rulesPageTitle => 'Reglas de progreso de entrenamiento';

  @override
  String get rulesPageSubtitle => 'Crea reglas reutilizables para cómo cambian pesos, repeticiones y series después de intentos de entrenamiento.';

  @override
  String get rulesHowDefaultsTitle => 'Cómo funcionan los valores predeterminados';

  @override
  String get rulesHowDefaultsBody => 'Los valores de aplicación se copian a los perfiles nuevos. Los del perfil se copian a planes nuevos, por lo que ediciones posteriores no reescriben planes existentes inesperadamente.';

  @override
  String get rulesAppDefaultsTitle => 'Valores predeterminados globales';

  @override
  String get rulesAppDefaultsSubtitle => 'Las reglas iniciales para nuevos perfiles de gimnasio.';

  @override
  String get rulesNoAppDefaults => 'Aún no se han creado reglas globales.';

  @override
  String get rulesAddApp => 'Añadir regla de aplicación';

  @override
  String get rulesGymProfilesTitle => 'Perfiles de gimnasio';

  @override
  String get rulesGymProfilesSubtitle => 'Cada perfil mantiene juntos sus valores predeterminados y reglas de plan.';

  @override
  String get rulesNoProfiles => 'Crea un perfil de gimnasio para añadir reglas de perfil y plan.';

  @override
  String rulesProfileSummary(int profileRules, int planRules) {
    return '$profileRules reglas de perfil • $planRules reglas de plan';
  }

  @override
  String get rulesProfileDefaultsTitle => 'Valores predeterminados de perfil';

  @override
  String get rulesProfileDefaultsSubtitle => 'Reglas iniciales para nuevos planes de este perfil.';

  @override
  String get rulesNoProfileDefaults => 'Este perfil no tiene reglas predeterminadas.';

  @override
  String get rulesAddProfile => 'Añadir regla de perfil';

  @override
  String get rulesPlansTitle => 'Planes';

  @override
  String get rulesNoPlans => 'Aún no hay planes para este perfil de gimnasio.';

  @override
  String get rulesPlanOnlySubtitle => 'Reglas usadas solo por este plan.';

  @override
  String get rulesNoPlanRules => 'Este plan no tiene reglas de progresión específicas.';

  @override
  String get rulesAddPlan => 'Añadir regla de plan';

  @override
  String get rulesAppDefaultsChip => 'Valores predeterminados';

  @override
  String get rulesProfilesChip => 'Perfiles';

  @override
  String get rulesPlansChip => 'Planes';

  @override
  String get rulesEditPlan => 'Editar regla';

  @override
  String get rulesAddPlanTitle => 'Añadir regla';

  @override
  String get commonRetry => 'Reintentar';

  @override
  String get safeFailureLoadTitle => 'No se pudo cargar';

  @override
  String get safeFailureSaveTitle => 'No se pudieron guardar los cambios';

  @override
  String get safeFailureActionTitle => 'No se pudo completar la acción';

  @override
  String get safeFailureValidation => 'Comprueba la información e inténtalo de nuevo.';

  @override
  String get safeFailureOffline => 'No hay conexión. Vuelve a conectarte e inténtalo de nuevo.';

  @override
  String get safeFailurePermission => 'Tonos no tiene permiso para completar esta acción. Comprueba los ajustes del dispositivo.';

  @override
  String get safeFailureStorage => 'Tonos no pudo acceder al almacenamiento del dispositivo. Comprueba el espacio disponible e inténtalo de nuevo.';

  @override
  String get safeFailureInvalidData => 'Los datos no se pudieron leer de forma segura. Elige otro archivo o inténtalo de nuevo.';

  @override
  String get safeFailureNotFound => 'Los datos solicitados ya no están disponibles. Actualiza e inténtalo de nuevo.';

  @override
  String get safeFailureTemporary => 'Esto no está disponible temporalmente. Inténtalo de nuevo.';

  @override
  String get safeFailureUnknown => 'Se produjo un problema. Inténtalo de nuevo.';

  @override
  String safeFailureWithGuidance(String summary, String guidance) {
    return '$summary $guidance';
  }

  @override
  String get flowPageTitle => 'Flujos de progresión de entrenamiento';

  @override
  String get flowPageSubtitle => 'Define las rutas que deciden cómo se aplican las acciones de progresión después de los resultados del entrenamiento.';

  @override
  String get flowHowCopiedTitle => 'Cómo se copian los flujos';

  @override
  String get flowHowCopiedBody => 'Los flujos de la aplicación se convierten en punto de partida para nuevos perfiles de gimnasio. Los flujos del gimnasio se convierten en punto de partida para nuevos planes. Las ediciones posteriores se limitan al flujo que abras aquí.';

  @override
  String get flowLoadError => 'No se pudieron cargar los flujos de progresión de entrenamiento.';

  @override
  String get flowAppDefaultsSubtitle => 'El flujo inicial para nuevos perfiles de gimnasio.';

  @override
  String get flowAppDefaultEntry => 'Flujo predeterminado de la aplicación';

  @override
  String get flowGymProfilesSubtitle => 'Cada perfil tiene valores predeterminados y sus propios flujos de planes.';

  @override
  String get flowNoProfiles => 'Crea un perfil de gimnasio para definir flujos de perfil y planes.';

  @override
  String get flowNoSavedYet => 'Aún no hay flujo guardado';

  @override
  String flowSummary(int nodes, int branches, int actions) {
    return '$nodes nodos | $branches ramas | $actions acciones';
  }

  @override
  String flowPlansAvailable(int count) {
    return '$count flujos de planes disponibles';
  }

  @override
  String get flowGymDefaultEntry => 'Flujo predeterminado del gimnasio';

  @override
  String get gymSettingsTitle => 'Ajustes de gimnasio y entrenamiento';

  @override
  String get gymSettingsSubtitle => 'Ajusta la generación, analítica y comportamiento del flujo de entrenamiento.';

  @override
  String get gymSettingsLogicTitle => 'Lógica de entrenamiento';

  @override
  String get gymSettingsLogicSubtitle => 'Ajustes que afectan la planificación y los entrenamientos generados.';

  @override
  String get gymSettingsWorkoutTitle => 'Ajustes de entrenamiento';

  @override
  String get gymSettingsWorkoutSubtitle => 'Límites de volumen, valores analíticos y controles de entrenamiento.';

  @override
  String get gymSettingsExitTitle => 'Salida de entrenamiento en curso';

  @override
  String get gymSettingsFlowToolsTitle => 'Herramientas de flujo';

  @override
  String get gymSettingsFlowToolsSubtitle => 'Gestiona rutas y acciones de progresión guardadas.';

  @override
  String get gymSettingsFlowsSubtitle => 'Edita flujos de progresión para valores predeterminados, gimnasios y planes.';

  @override
  String get gymSettingsRulesSubtitle => 'Gestiona reglas de progresión de peso, repeticiones y series.';

  @override
  String get gymExitAsk => 'Preguntar siempre';

  @override
  String get gymExitDiscard => 'Cancelar entrenamiento';

  @override
  String get gymExitSave => 'Finalizar y guardar';

  @override
  String get gymExitAskBody => 'Preguntar antes de finalizar el trabajo completado.';

  @override
  String get gymExitDiscardBody => 'Cancelar sin guardar el trabajo completado.';

  @override
  String get gymExitSaveBody => 'Guardar el trabajo completado en el Registro.';

  @override
  String get commonAll => 'Todo';

  @override
  String get catalogGuideChooseTitle => 'Elige un ejercicio';

  @override
  String get catalogGuideChooseBody => 'Toca una fila de ejercicio para seleccionarlo. La búsqueda o los filtros te ayudan a encontrar el movimiento adecuado.';

  @override
  String get catalogGuideAddTitle => 'Añádelo a tu plan';

  @override
  String catalogGuideAddBody(String exerciseName) {
    return 'Toca + para añadir $exerciseName y volver a tu plan.';
  }

  @override
  String get catalogGuideSearchTitle => 'Buscar ejercicios';

  @override
  String get catalogGuideSearchBody => 'Busca por nombre de ejercicio cuando ya sabes qué movimiento quieres.';

  @override
  String get catalogFilters => 'Filtros';

  @override
  String get catalogGuideFiltersBody => 'Filtra por perfil de gimnasio, equipo, parte corporal o músculo para limitar el catálogo rápidamente.';

  @override
  String get catalogGuideRowsTitle => 'Filas de ejercicios';

  @override
  String get catalogGuideRowsBody => 'Cada fila muestra el equipo y un mapa de calor. Toca el mapa para ver detalles o selecciona la fila al elegir un ejercicio.';

  @override
  String get catalogSelectedFilters => 'Filtros seleccionados';

  @override
  String get catalogUseWorkspaceProfile => 'Usar perfil de espacio';

  @override
  String get catalogWorkspaceProfile => 'Perfil de espacio';

  @override
  String get catalogEquipment => 'Equipo';

  @override
  String get catalogFocusArea => 'Área de enfoque';

  @override
  String get catalogSpecificMuscle => 'Músculo específico';

  @override
  String get catalogPageTitle => 'Catálogo de ejercicios';

  @override
  String get catalogSearchExercises => 'Buscar ejercicios';

  @override
  String get catalogNoMatches => 'Ningún ejercicio coincide con los filtros.';

  @override
  String get catalogOpenExerciseInfo => 'Abrir información del ejercicio';

  @override
  String get commonClose => 'Cerrar';

  @override
  String get exerciseDetailOpenImage => 'Abrir imagen del ejercicio';

  @override
  String get exerciseDetailTutorialTitle => 'Detalles del ejercicio';

  @override
  String get exerciseDetailTutorialBody => 'El título de la hoja es el ejercicio que abriste. Ciérrala desde aquí cuando termines.';

  @override
  String get exerciseDetailTabsTutorialTitle => 'Detalles, métricas, registros';

  @override
  String get exerciseDetailTabsTutorialBody => 'Usa estas pestañas para alternar entre instrucciones, mejores levantamientos y registros de entrenamientos recientes.';

  @override
  String get exerciseDetailContextTutorialTitle => 'Contexto del ejercicio';

  @override
  String get exerciseDetailContextTutorialBody => 'La pestaña de detalles muestra equipo, partes del cuerpo entrenadas, músculos y notas de forma del ejercicio.';

  @override
  String get exerciseDetailSessionOpenFailed => 'No se pudo abrir la sesión de entrenamiento.';

  @override
  String get exerciseDetailSessionNotFound => 'No se encontró la sesión de entrenamiento.';

  @override
  String get exerciseDetailNoEquipment => 'No hay equipo indicado para este ejercicio.';

  @override
  String get exerciseDetailTargetAnatomy => 'Anatomía objetivo';

  @override
  String get exerciseDetailBodyParts => 'Partes del cuerpo';

  @override
  String get exerciseDetailNoBodyParts => 'No hay partes del cuerpo indicadas.';

  @override
  String get exerciseDetailMuscles => 'Músculos';

  @override
  String get exerciseDetailNoMuscles => 'No hay músculos indicados.';

  @override
  String get exerciseDetailSetup => 'Preparación';

  @override
  String get exerciseDetailNoSetup => 'No se proporcionaron instrucciones de preparación.';

  @override
  String get exerciseDetailExecution => 'Ejecución';

  @override
  String get exerciseDetailNoExecution => 'No se proporcionaron notas de ejecución.';

  @override
  String get exerciseDetailTips => 'Consejos';

  @override
  String get exerciseDetailNoTips => 'No hay consejos adicionales.';

  @override
  String get exerciseDetailFormGuide => 'Guía de forma';

  @override
  String get exerciseDetailOpenHeatmap => 'Abrir mapa de calor corporal objetivo';

  @override
  String get exerciseDetailNoHeatmap => 'No hay áreas corporales objetivo disponibles';

  @override
  String get exerciseDetailZoomHint => 'Pellizca o arrastra para hacer zoom';

  @override
  String get exerciseDetailLoadingBestLifts => 'Cargando mejores levantamientos';

  @override
  String get exerciseDetailLoadingBestLiftsBody => 'Se están calculando tus registros de series completadas.';

  @override
  String get exerciseDetailMetricsUnavailable => 'Métricas no disponibles';

  @override
  String get exerciseDetailMetricsUnavailableBody => 'Intenta volver a abrir este ejercicio para cargar los registros de series completadas.';

  @override
  String get exerciseDetailNoBestLifts => 'Aún no hay mejores levantamientos';

  @override
  String get exerciseDetailNoBestLiftsBody => 'Completa una serie con peso para este ejercicio y empieza a registrar tus mejores repeticiones.';

  @override
  String get exerciseDetailWeek => 'Semana';

  @override
  String get exerciseDetailMonth => 'Mes';

  @override
  String get exerciseDetailAllTime => 'Todo el tiempo';

  @override
  String exerciseDetailTimeframeMetrics(String timeframe) {
    return 'Métricas de $timeframe';
  }

  @override
  String get exerciseDetailTopEstimatedOneRm => 'Mejor 1RM est.';

  @override
  String get exerciseDetailVolumeBest => 'Mejor volumen';

  @override
  String get exerciseDetailRepBests => 'Mejores repeticiones';

  @override
  String get exerciseDetailRepBestsBody => 'Mejor peso completado para cada número de repeticiones';

  @override
  String exerciseDetailRanges(int count) {
    return '$count rangos';
  }

  @override
  String get exerciseDetailHistoryLoadFailed => 'No se pudo cargar el historial del ejercicio.';

  @override
  String get exerciseDetailNoHistory => 'No hay historial para este ejercicio.';

  @override
  String get exerciseDetailPerformanceTrend => 'Tendencia de rendimiento';

  @override
  String get exerciseDetailBestWeight => 'Mejor peso';

  @override
  String get exerciseDetailEstimatedOneRm => '1RM estimado';

  @override
  String get exerciseDetailLoadingSessions => 'Cargando sesiones';

  @override
  String get exerciseDetailLoadMoreSessions => 'Cargar 10 sesiones más';

  @override
  String get exerciseDetailResizeLabel => 'Cambiar tamaño de detalles del ejercicio';

  @override
  String get exerciseDetailResizeHint => 'Arrastra hacia arriba o abajo para cambiar el tamaño de la hoja';

  @override
  String get exerciseDetailTabDetails => 'Detalles';

  @override
  String get exerciseDetailTabMetrics => 'Métricas';

  @override
  String get exerciseDetailTabRecords => 'Registros';

  @override
  String exerciseDetailOpenWorkoutWithSets(int count) {
    return 'Abrir entrenamiento con $count series completadas';
  }

  @override
  String exerciseDetailSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count series',
      one: '1 serie',
    );
    return '$_temp0';
  }

  @override
  String exerciseDetailEstimatedMax(String weight) {
    return 'ERM $weight';
  }

  @override
  String get exerciseDetailReps => 'reps';

  @override
  String get exerciseDetailSetVolume => 'Volumen de la serie';

  @override
  String get exerciseDetailNoChartData => 'Aún no hay registros de series completadas para graficar.';

  @override
  String get exerciseDetailWeightAbbreviation => 'Pes.';

  @override
  String get exerciseDetailEstimatedAbbreviation => 'Est.';

  @override
  String get exerciseDetailTopAbbreviation => 'Máx.';

  @override
  String exerciseDetailSectionLabel(String title) {
    return 'Sección $title';
  }

  @override
  String get logbookTutorialCalendarTitle => 'Calendario del registro';

  @override
  String get logbookTutorialCalendarBody => 'Usa M, 3M, A y 4A para explorar el historial. Selecciona un día, semana, mes o año para ver sesiones y estadísticas de ese período.';

  @override
  String get fullHistoryTitle => 'Todas las sesiones';

  @override
  String get fullHistoryLoadError => 'No se pudieron cargar las sesiones guardadas.';

  @override
  String get fullHistoryEmpty => 'No hay sesiones guardadas.';

  @override
  String fullHistorySessionSummary(String date, String duration) {
    return '$date - $duration';
  }

  @override
  String get weeklySetsTitle => 'Resumen semanal de series';

  @override
  String get weeklySetsLoadError => 'No se pudo cargar tu resumen semanal de entrenamiento.';

  @override
  String get weeklySetsBodyParts => 'Partes del cuerpo';

  @override
  String get weeklySetsMuscles => 'Músculos';

  @override
  String get weeklySetsTotal => 'Total de series';

  @override
  String get weeklySetsTime => 'Tiempo';

  @override
  String get weeklySetsVolume => 'Volumen';

  @override
  String get weeklySetsNoBodyParts => 'Aún no hay series de partes corporales.';

  @override
  String get weeklySetsNoMuscles => 'Aún no hay series musculares.';

  @override
  String weeklySetsCount(String count) {
    return '$count series';
  }

  @override
  String get weeklySetsTutorialOverviewTitle => 'Resumen semanal';

  @override
  String get weeklySetsTutorialOverviewBody => 'Resume los últimos siete días con un mapa de calor y el total de series, tiempo y volumen.';

  @override
  String get weeklySetsTutorialAnatomyTitle => 'Partes corporales o músculos';

  @override
  String get weeklySetsTutorialAnatomyBody => 'Alterna entre unidades de series por parte corporal y por músculo individual.';

  @override
  String get weeklySetsTutorialStatusTitle => 'Estado de series';

  @override
  String get weeklySetsTutorialStatusBody => 'Cada fila se colorea según tu trabajo reciente esté debajo, dentro o sobre su rango recomendado. Toca una fila para ver ejercicios vinculados.';

  @override
  String get workoutDetailTutorialSummaryTitle => 'Resumen del entrenamiento';

  @override
  String get workoutDetailTutorialSummaryBody => 'Revisa el total de series, volumen, duración, cantidad de ejercicios y las partes del cuerpo trabajadas.';

  @override
  String get workoutDetailTutorialExercisesTitle => 'Registros de ejercicios';

  @override
  String get workoutDetailTutorialExercisesBody => 'Cada ejercicio muestra las series completadas de esa sesión. Toca detalles para inspeccionar el ejercicio.';

  @override
  String get workoutDetailTutorialEditTitle => 'Editar sesión';

  @override
  String get workoutDetailTutorialEditBody => 'Usa el modo de edición si necesitas corregir series, repeticiones o ejercicios después del entrenamiento.';

  @override
  String get workoutDetailTutorialReuseTitle => 'Reutiliza este entrenamiento';

  @override
  String get workoutDetailTutorialReuseBody => 'Haz el entrenamiento de nuevo o guarda la sesión completada como un plan reutilizable.';

  @override
  String get workoutDetailDeleteTitle => 'Eliminar sesión';

  @override
  String get workoutDetailDeleteBody => '¿Seguro que quieres eliminar esta sesión?';

  @override
  String get workoutDetailDeleteFailed => 'No se pudo eliminar esta sesión.';

  @override
  String get workoutDetailChangesSaved => 'Cambios guardados.';

  @override
  String get workoutDetailSaveFailed => 'No se pudieron guardar los cambios. La sesión anterior no ha cambiado.';

  @override
  String get workoutDetailFinishCurrentFirst => 'Termina tu entrenamiento actual antes de repetir este.';

  @override
  String get workoutDetailOngoingWorkoutKept => 'Se mantuvo tu entrenamiento en curso. Termínalo o cancélalo antes de repetir este entrenamiento.';

  @override
  String get workoutDetailRepeatFailed => 'No se pudo repetir este entrenamiento.';

  @override
  String get workoutDetailSaveAsPlan => 'Guardar como plan';

  @override
  String get workoutDetailPlanName => 'Nombre del plan';

  @override
  String workoutDetailPlanSaved(String name) {
    return '\"$name\" se guardó como plan.';
  }

  @override
  String get workoutDetailPlanSaveFailed => 'No se pudo guardar el plan.';

  @override
  String workoutDetailDefaultPlanName(String date) {
    return 'Entrenamiento $date';
  }

  @override
  String get workoutDetailUnsavedTitle => 'Cambios sin guardar';

  @override
  String get workoutDetailUnsavedBody => 'Tienes cambios sin guardar. ¿Quieres descartarlos y salir?';

  @override
  String get workoutDetailDiscard => 'Descartar';

  @override
  String get workoutDetailTitle => 'Detalles del entrenamiento';

  @override
  String get workoutDetailStopEditing => 'Dejar de editar';

  @override
  String get workoutDetailEditSession => 'Editar sesión';

  @override
  String get workoutDetailDeleteSession => 'Eliminar sesión';

  @override
  String get workoutDetailLoadFailed => 'No se pudo cargar esta sesión.';

  @override
  String get workoutDetailEmpty => 'No hay ejercicios en esta sesión.';

  @override
  String get workoutDetailSaveChanges => 'Guardar cambios';

  @override
  String get workoutDetailRepeat => 'Hacer el entrenamiento de nuevo';

  @override
  String get workoutDetailPastWorkout => 'Entrenamiento anterior';

  @override
  String workoutDetailCompletedSets(int count) {
    return '$count series completadas';
  }

  @override
  String get workoutDetailVolume => 'Volumen';

  @override
  String get workoutDetailDuration => 'Duración';

  @override
  String get workoutDetailExercises => 'Ejercicios';

  @override
  String get workoutDetailExerciseInfo => 'Información del ejercicio';

  @override
  String get workoutDetailBest => 'Mejor';

  @override
  String workoutDetailEstimatedOneRm(String weight) {
    return '1RM = $weight';
  }

  @override
  String get logbookCalendarLoadFailed => 'No se pudo cargar el calendario de entrenamientos.';

  @override
  String get logbookNoWorkouts => 'No hay entrenamientos registrados';

  @override
  String logbookWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entrenamientos',
      one: '1 entrenamiento',
    );
    return '$_temp0';
  }

  @override
  String get logbookPreviousMonth => 'Mes anterior';

  @override
  String get logbookNextMonth => 'Mes siguiente';

  @override
  String get logbookPreviousThreeMonths => '3 meses anteriores';

  @override
  String get logbookNextThreeMonths => 'Próximos 3 meses';

  @override
  String get logbookPreviousYear => 'Año anterior';

  @override
  String get logbookNextYear => 'Año siguiente';

  @override
  String logbookWeekShort(int week) {
    return 'S$week';
  }

  @override
  String logbookMonthWeek(String month, int week) {
    return '$month, semana $week';
  }

  @override
  String get logbookWorkouts => 'Entrenamientos';

  @override
  String get logbookTotalTime => 'Tiempo total';

  @override
  String get logbookTotalVolume => 'Volumen total';

  @override
  String get logbookViewAllSessions => 'Ver todas las sesiones';

  @override
  String logbookSessionSummary(String duration, int exercises, int sets, String volume) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises ejercicios',
      one: '1 ejercicio',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets series',
      one: '1 serie',
    );
    return '$duration - $_temp0 - $_temp1 - $volume';
  }

  @override
  String durationHours(int hours) {
    return '$hours h';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds s';
  }

  @override
  String durationHoursMinutes(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String durationMinutesSeconds(int minutes, int seconds) {
    return '$minutes min $seconds s';
  }

  @override
  String get dashboardHideSection => 'Ocultar sección';

  @override
  String get dashboardAllSectionsShown => 'Se muestran todas las secciones';

  @override
  String dashboardHiddenSectionCount(int count) {
    return '$count secciones ocultas';
  }

  @override
  String get dashboardShowHiddenSections => 'Mostrar secciones ocultas';

  @override
  String get dashboardReset => 'Restablecer panel';

  @override
  String get dashboardEmptyTitle => 'Tu panel está vacío';

  @override
  String get dashboardEmptyBody => 'Vuelve a añadir cualquier sección cuando estés listo.';

  @override
  String get dashboardCustomize => 'Personalizar panel';

  @override
  String get dashboardSectionQuickActionsTitle => 'Acciones rápidas';

  @override
  String get dashboardSectionQuickActionsBody => 'Registra una medición o inicia un entrenamiento.';

  @override
  String get dashboardSectionTrainingTitle => 'Listo para entrenar';

  @override
  String get dashboardSectionTrainingBody => 'Selecciona tu perfil de gimnasio y planes, e inicia una sesión.';

  @override
  String get dashboardSectionNutritionTitle => 'Panel de nutrición';

  @override
  String get dashboardSectionNutritionBody => 'Revisa los objetivos actuales de calorías y macros.';

  @override
  String get dashboardSectionDataRecordsTitle => 'Datos y registros';

  @override
  String get dashboardSectionDataRecordsBody => 'Revisa y añade entradas diarias de nutrición.';

  @override
  String get dashboardSectionWeeklyFocusTitle => 'Enfoque semanal';

  @override
  String get dashboardSectionWeeklyFocusBody => 'Revisa el trabajo de partes corporales y músculos de los últimos 7 días.';

  @override
  String get dashboardSectionWorkoutReportTitle => 'Informe de entrenamiento';

  @override
  String get dashboardSectionWorkoutReportBody => 'Compara cantidad, tiempo y volumen de entrenamiento a lo largo del tiempo.';

  @override
  String get dashboardSectionExerciseProgressTitle => 'Progreso de ejercicios';

  @override
  String get dashboardSectionExerciseProgressBody => 'Sigue las tendencias de fuerza de tus ejercicios seleccionados.';

  @override
  String get dashboardSectionHistoryTitle => 'Historial de entrenamiento';

  @override
  String get dashboardSectionHistoryBody => 'Compara totales y enfoque de entrenamiento entre períodos.';

  @override
  String get dashboardSectionHealthTrendsTitle => 'Tendencias de salud';

  @override
  String get dashboardSectionHealthTrendsBody => 'Sigue mediciones como peso corporal y tamaños.';

  @override
  String get dashboardSectionRecentWorkoutsTitle => 'Entrenamientos recientes';

  @override
  String get dashboardSectionRecentWorkoutsBody => 'Abre tus últimas sesiones de entrenamiento completadas.';

  @override
  String get dashboardSectionActivePlansTitle => 'Planes activos';

  @override
  String get dashboardSectionActivePlansBody => 'Mantén cerca los planes que usas más a menudo.';

  @override
  String get dashboardSectionArchivedPlansTitle => 'Planes archivados';

  @override
  String get dashboardSectionArchivedPlansBody => 'Explora planes que no están activos actualmente.';

  @override
  String get dashboardSectionPremadePlansTitle => 'Planes prediseñados';

  @override
  String get dashboardSectionPremadePlansBody => 'Explora rutinas que se pueden añadir a este perfil.';

  @override
  String get dashboardSectionPlanToolsTitle => 'Herramientas de planes';

  @override
  String get dashboardSectionPlanToolsBody => 'Genera un plan equilibrado o crea uno manualmente.';

  @override
  String get dashboardSectionCatalogTitle => 'Catálogo de ejercicios';

  @override
  String get dashboardSectionCatalogBody => 'Abre tus ejercicios más usados y el catálogo completo.';

  @override
  String get dashboardSectionAnatomyTitle => 'Anatomía objetivo';

  @override
  String get dashboardSectionAnatomyBody => 'Revisa las partes corporales y músculos que más entrenas.';

  @override
  String get dashboardSectionFallbackTitle => 'Sección del panel';

  @override
  String get dashboardSectionFallbackBody => 'Una sección del panel.';

  @override
  String get dashboardTitle => 'Panel';

  @override
  String get dashboardDoneCustomizing => 'Personalización terminada';

  @override
  String get dashboardQuickActions => 'Acciones rápidas';

  @override
  String get dashboardMeasurement => 'Medición';

  @override
  String get dashboardResumeWorkout => 'Reanudar entrenamiento';

  @override
  String get dashboardStartWorkout => 'Iniciar entrenamiento';

  @override
  String dashboardTodayAt(String time) {
    return 'Hoy, $time';
  }

  @override
  String get dashboardRecentWorkouts => 'Entrenamientos recientes';

  @override
  String get dashboardViewAll => 'Ver todo';

  @override
  String get dashboardRecentWorkoutsFailed => 'No se pudieron cargar los entrenamientos recientes.';

  @override
  String get dashboardRecentWorkoutsEmpty => 'Termina un entrenamiento y aparecerá aquí.';

  @override
  String get userInfoProfileUpdateNote => 'Actualización de perfil';

  @override
  String get userInfoChangesSaved => 'Cambios guardados';

  @override
  String get userInfoSaveFailed => 'No se pudieron guardar los cambios.';

  @override
  String get userInfoTitle => 'Información de usuario';

  @override
  String get userInfoSubtitle => 'Mantén disponibles los datos básicos del perfil para los cálculos de la aplicación.';

  @override
  String get userInfoIdentityTitle => 'Identidad';

  @override
  String get userInfoIdentitySubtitle => 'Datos personales básicos.';

  @override
  String get userInfoName => 'Nombre';

  @override
  String get userInfoNameHint => 'Introduce tu nombre';

  @override
  String get userInfoGender => 'Género';

  @override
  String get userInfoDateOfBirth => 'Fecha de nacimiento';

  @override
  String get userInfoDateHint => 'AAAA-MM-DD';

  @override
  String get userInfoBodyMetricsTitle => 'Métricas corporales';

  @override
  String get userInfoBodyMetricsSubtitle => 'Detalles opcionales usados por las estimaciones de progreso y nutrición.';

  @override
  String get userInfoHeight => 'Estatura';

  @override
  String get userInfoHeightHint => 'p. ej., 5\'10\" o 178 cm';

  @override
  String get userInfoCurrentWeight => 'Peso actual';

  @override
  String get userInfoWeightPoundsHint => 'p. ej., 160';

  @override
  String get userInfoWeightKilogramsHint => 'p. ej., 72';

  @override
  String get userInfoBodyFat => 'Estimación de % de grasa corporal';

  @override
  String get userInfoActivityTitle => 'Contexto de actividad';

  @override
  String get userInfoActivitySubtitle => 'Se usa más adelante para recomendaciones y estimaciones de salud.';

  @override
  String get userInfoWeightTrend => 'Tendencia de peso';

  @override
  String get userInfoAverageSteps => 'Promedio estimado de pasos';

  @override
  String get userInfoGenderMale => 'Hombre';

  @override
  String get userInfoGenderFemale => 'Mujer';

  @override
  String get userInfoGenderOther => 'Otro';

  @override
  String get userInfoGenderPreferNotToSay => 'Prefiero no decirlo';

  @override
  String get userInfoTrendGaining => 'Ganando peso';

  @override
  String get userInfoTrendLosing => 'Perdiendo peso';

  @override
  String get userInfoTrendMaintaining => 'Manteniendo el peso';

  @override
  String get userInfoTrendNotSure => 'No estoy seguro';

  @override
  String get userInfoActivityLow => 'Baja (0-5 mil)';

  @override
  String get userInfoActivityModerate => 'Moderada (5-15 mil)';

  @override
  String get userInfoActivityHigh => 'Alta (15 mil+)';

  @override
  String get userInfoSaveChanges => 'Guardar cambios';

  @override
  String get tutorialsSettingsTitle => 'Tutoriales guiados';

  @override
  String get tutorialsSettingsSubtitle => 'Reproduce un recorrido cuando quieras un repaso rápido.';

  @override
  String get tutorialsControlsTitle => 'Controles de tutoriales';

  @override
  String get tutorialsControlsSubtitle => '¿Probando o empezando de nuevo?';

  @override
  String get tutorialsResetAllTitle => 'Restablecer todos los tutoriales';

  @override
  String get tutorialsResetAllSubtitle => 'Vuelve a hacer disponibles todos los tutoriales guiados.';

  @override
  String get tutorialsResetAll => 'Restablecer todo';

  @override
  String get tutorialsResetAllMessage => 'Todos los tutoriales se han restablecido.';

  @override
  String get tutorialsHowItWorksTitle => 'Cómo funcionan los tutoriales';

  @override
  String get tutorialsHowItWorksBody => 'Los tutoriales aparecen una vez y luego no estorban. Expande un grupo para restablecer un recorrido específico.';

  @override
  String get tutorialsMainTabsTitle => 'Pestañas principales';

  @override
  String get tutorialsMainTabsSubtitle => 'Reproduce recorridos de cada área principal.';

  @override
  String get tutorialsWorkoutTitle => 'Entrenamiento';

  @override
  String get tutorialsWorkoutSubtitle => 'Ayuda para registrar tu primera sesión.';

  @override
  String get tutorialsPlansTitle => 'Planes y entrenamientos';

  @override
  String get tutorialsPlansSubtitle => 'Reproduce la ayuda para crear, editar planes y ver detalles de entrenamientos.';

  @override
  String get tutorialsCatalogTitle => 'Catálogo y anatomía';

  @override
  String get tutorialsCatalogSubtitle => 'Reproduce la ayuda del catálogo de ejercicios y anatomía objetivo.';

  @override
  String get tutorialsProgressTitle => 'Progreso y ajustes';

  @override
  String get tutorialsProgressSubtitle => 'Reproduce la ayuda de detalles de progreso y páginas de ajustes.';

  @override
  String tutorialsReplayTitle(String topic) {
    return 'Reproducir tutorial de $topic';
  }

  @override
  String tutorialsShownNextTime(String topic) {
    return 'Se mostrará la próxima vez que abras $topic.';
  }

  @override
  String tutorialsWillReplayNextTime(String topic) {
    return 'El tutorial de $topic se reproducirá la próxima vez.';
  }

  @override
  String get tutorialsReset => 'Restablecer';

  @override
  String get tutorialsTopicTrain => 'Entrenamiento';

  @override
  String get tutorialsTopicCatalog => 'Catálogo';

  @override
  String get tutorialsTopicLogbook => 'Registro';

  @override
  String get tutorialsTopicProgress => 'Progreso';

  @override
  String get tutorialsTopicProfile => 'Perfil';

  @override
  String get tutorialsTopicFirstWorkout => 'primer entrenamiento';

  @override
  String get tutorialsTopicGeneratePlans => 'Generar planes';

  @override
  String get tutorialsTopicOptimizedSettings => 'ajustes de entrenamiento optimizado';

  @override
  String get tutorialsTopicPremadePlans => 'Planes prediseñados';

  @override
  String get tutorialsTopicPlanManagement => 'gestión de planes';

  @override
  String get tutorialsTopicPlanDetail => 'detalles del plan';

  @override
  String get tutorialsTopicPlanBuilder => 'creador de planes';

  @override
  String get tutorialsTopicWorkoutDetail => 'detalles del entrenamiento';

  @override
  String get tutorialsTopicExerciseCatalog => 'Catálogo de ejercicios';

  @override
  String get tutorialsTopicExerciseDetail => 'detalles del ejercicio';

  @override
  String get tutorialsTopicTargetAnatomy => 'Anatomía objetivo';

  @override
  String get tutorialsTopicBodypartDetail => 'detalles de parte corporal';

  @override
  String get tutorialsTopicMuscleDetail => 'detalles de músculo';

  @override
  String get tutorialsTopicWeeklySets => 'Resumen semanal de series';

  @override
  String get tutorialsTopicExerciseProgress => 'progreso de ejercicio';

  @override
  String get tutorialsTopicMeasurementTrend => 'tendencia de medición';

  @override
  String get tutorialsTopicGymProfile => 'editor de perfil de gimnasio';

  @override
  String get tutorialsTopicUiAppearance => 'UI y apariencia';

  @override
  String get tutorialsTopicDatabaseSettings => 'Ajustes de base de datos';

  @override
  String get tutorialsTopicGuide => 'ayuda guiada';

  @override
  String get anatomyLibraryTitle => 'Biblioteca de enfoque de ejercicios';

  @override
  String get anatomyBodyParts => 'Partes del cuerpo';

  @override
  String get anatomyMuscles => 'Músculos';

  @override
  String get anatomyLoadFailed => 'No se pudieron cargar los filtros de anatomía.';

  @override
  String get anatomySearchLabel => 'Buscar partes del cuerpo o músculos';

  @override
  String get anatomyNoBodyParts => 'Ninguna parte corporal coincide con tu búsqueda.';

  @override
  String get anatomyNoMuscles => 'Ningún músculo coincide con tu búsqueda.';

  @override
  String anatomyExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios',
      one: '1 ejercicio',
    );
    return '$_temp0';
  }

  @override
  String get anatomyTutorialSearchTitle => 'Buscar anatomía';

  @override
  String get anatomyTutorialSearchBody => 'Busca una parte corporal o músculo específico cuando quieras opciones de ejercicio dirigidas.';

  @override
  String get anatomyTutorialListsTitle => 'Partes corporales y músculos';

  @override
  String get anatomyTutorialListsBody => 'Cambia de pestaña y toca cualquier fila para ver ejercicios vinculados, totales recientes y límites recomendados.';

  @override
  String anatomyTargetExercises(String name) {
    return 'Ejercicios de $name';
  }

  @override
  String get anatomyBodypartLoadFailed => 'No se pudo cargar esta parte corporal.';

  @override
  String get anatomyMuscleLoadFailed => 'No se pudo cargar este músculo.';

  @override
  String anatomyRecommendedSetsUpdated(String name) {
    return 'Series recomendadas actualizadas para $name.';
  }

  @override
  String get anatomySaveFailed => 'No se pudieron guardar los cambios.';

  @override
  String anatomyLinkedExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count ejercicios vinculados',
      one: '1 ejercicio vinculado',
    );
    return '$_temp0';
  }

  @override
  String get anatomyDoneLastSevenDays => 'Completado (7 días)';

  @override
  String get anatomySetsLastSevenDays => 'Series de los últimos 7 días';

  @override
  String anatomySetUnits(String count) {
    return '$count series';
  }

  @override
  String get anatomyRecommended => 'Recomendado';

  @override
  String get anatomyNotSet => 'No definido';

  @override
  String anatomySetRange(String min, String max) {
    return '$min-$max series';
  }

  @override
  String get anatomyAssociatedMuscles => 'Músculos asociados';

  @override
  String get anatomyRelatedBodyParts => 'Partes corporales relacionadas';

  @override
  String get anatomyNoMuscleLinks => 'Aún no se han añadido vínculos de músculos para esta parte corporal.';

  @override
  String get anatomyNoBodyPartLinks => 'Aún no se han añadido vínculos de partes corporales para este músculo.';

  @override
  String get anatomyExercises => 'Ejercicios';

  @override
  String anatomyNoExercisesFor(String name) {
    return 'Actualmente no hay ejercicios vinculados a $name.';
  }

  @override
  String get anatomyNoEquipment => 'No hay equipo indicado';

  @override
  String get anatomyNoMusclesListed => 'No hay músculos indicados';

  @override
  String get anatomyNoBodyPartsListed => 'No hay partes corporales indicadas';

  @override
  String anatomyOpenedFrom(String name) {
    return 'Abierto desde $name';
  }

  @override
  String anatomyRankForMuscle(int rank, String bodyparts) {
    return 'Rango $rank para este músculo - $bodyparts';
  }

  @override
  String get anatomyTutorialDetailTitle => 'Detalle de anatomía';

  @override
  String get anatomyTutorialBodypartDetailBody => 'El encabezado muestra series recientes, límites de series recomendados y enlaces de anatomía relacionados.';

  @override
  String get anatomyTutorialMuscleDetailTitle => 'Detalle de músculo';

  @override
  String get anatomyTutorialMuscleDetailBody => 'El encabezado muestra series recientes, límites recomendados y partes corporales relacionadas.';

  @override
  String get anatomyTutorialLinkedExercisesTitle => 'Ejercicios vinculados';

  @override
  String get anatomyTutorialBodypartExercisesBody => 'Estos ejercicios están conectados a este objetivo. Toca uno para abrir sus detalles completos.';

  @override
  String get anatomyTutorialMuscleExercisesBody => 'Los ejercicios se clasifican según cuánto entrenan directamente este músculo. Toca uno para ver los detalles completos.';

  @override
  String get settingsWorkoutTitle => 'Ajustes de entrenamiento';

  @override
  String get settingsWorkoutSubtitle => 'Ajusta cómo la aplicación entiende anatomía, sesgo de entrenamiento y objetivos de volumen.';

  @override
  String get settingsTrainingBiasTitle => 'Sesgo de entrenamiento';

  @override
  String get settingsTrainingBiasSubtitle => 'Controles usados por planes generados y entrenamientos optimizados.';

  @override
  String get settingsBodyPartRankings => 'Clasificaciones de partes corporales';

  @override
  String get settingsBodyPartRankingsSubtitle => 'Prioriza qué partes corporales deben recibir más trabajo.';

  @override
  String get settingsMuscleRankings => 'Clasificaciones musculares';

  @override
  String get settingsMuscleRankingsSubtitle => 'Prioriza músculos específicos dentro del modelo anatómico.';

  @override
  String get settingsVolumeBoundaries => 'Límites de volumen';

  @override
  String get settingsVolumeBoundariesSubtitle => 'Define rangos semanales recomendados para partes corporales y músculos.';

  @override
  String get settingsExerciseDefinitionsTitle => 'Definiciones de ejercicios';

  @override
  String get settingsExerciseDefinitionsSubtitle => 'Mantén los datos de anatomía y ejercicios usados por la aplicación.';

  @override
  String get settingsAnatomyMapping => 'Mapeo de parte corporal / músculo';

  @override
  String get settingsAnatomyMappingSubtitle => 'Elige qué músculos pertenecen a cada parte corporal.';

  @override
  String get settingsExerciseSetAllocation => 'Asignación de series del ejercicio';

  @override
  String get settingsExerciseSetAllocationSubtitle => 'Revisa cómo cada ejercicio contribuye a músculos y partes corporales.';

  @override
  String get settingsExerciseEditor => 'Editor de ejercicios';

  @override
  String get settingsExerciseEditorSubtitle => 'Actualiza nombres, detalles, equipo y mapeos de ejercicios.';

  @override
  String get commonCopy => 'Copiar';

  @override
  String get commonImport => 'Importar';

  @override
  String get commonExport => 'Exportar';

  @override
  String get databaseExportTitle => 'Exportar base de datos';

  @override
  String get databaseImportTitle => 'Importar base de datos';

  @override
  String get databasePasteJson => 'Pega JSON aquí';

  @override
  String get databaseCopied => 'Copiado al portapapeles';

  @override
  String databaseExportFailed(String error) {
    return 'Falló la exportación: $error';
  }

  @override
  String get databaseImportSucceeded => 'Importación correcta';

  @override
  String databaseImportFailed(String error) {
    return 'Falló la importación: $error';
  }

  @override
  String get settingsTitle => 'Ajustes';

  @override
  String get nutritionSettingsTitle => 'Ajustes de dieta y nutrición';

  @override
  String get nutritionSettingsSubtitle => 'Configura objetivos nutricionales y preferencias relacionadas con alimentos.';

  @override
  String get nutritionCurrentGoals => 'Objetivos actuales';

  @override
  String get nutritionGoals => 'Objetivos';

  @override
  String get nutritionGoalsSubtitle => 'Define los objetivos usados por el seguimiento nutricional.';

  @override
  String get nutritionManualGoals => 'Definir objetivos nutricionales manualmente';

  @override
  String get nutritionManualGoalsSubtitle => 'Introduce tú mismo las calorías, macros y nutrientes clave.';

  @override
  String get nutritionGoalsSaved => 'Objetivos guardados';

  @override
  String nutritionGoalSummary(String calories, String protein, String carbs, String fat, String fiber, String sugar, String satFat, String sodium) {
    return 'Calorías: $calories / Proteína: $protein / Carbohidratos: $carbs / Grasa: $fat / Fibra: $fiber / Azúcar: $sugar / Grasa sat.: $satFat / Sodio: $sodium';
  }

  @override
  String get progressSettingsTitle => 'Ajustes de progreso';

  @override
  String get progressSettingsSubtitle => 'Gestiona medidas corporales y configuración de seguimiento de tendencias.';

  @override
  String get progressMeasurements => 'Mediciones';

  @override
  String get progressMeasurementsSubtitle => 'Configura las métricas corporales que quieres seguir con el tiempo.';

  @override
  String get progressMeasurementLibrary => 'Biblioteca de mediciones';

  @override
  String get progressMeasurementLibrarySubtitle => 'Gestiona peso, estatura, medidas corporales y métricas personalizadas.';

  @override
  String get nutritionManualGoalsTitle => 'Objetivos nutricionales manuales';

  @override
  String get nutritionManualGoalsPageSubtitle => 'Define manualmente objetivos de calorías, macros y nutrientes.';

  @override
  String get nutritionSaveGoals => 'Guardar objetivos';

  @override
  String get nutritionSaving => 'Guardando...';

  @override
  String get nutritionStartDate => 'Fecha de inicio';

  @override
  String get nutritionGoalStarts => 'El objetivo comienza';

  @override
  String get nutritionCaloriesAndMacros => 'Calorías y macros';

  @override
  String get nutritionAdditionalNutrients => 'Nutrientes adicionales';

  @override
  String get nutritionCalories => 'Calorías (kcal)';

  @override
  String get nutritionProtein => 'Proteína (g)';

  @override
  String get nutritionCarbs => 'Carbohidratos (g)';

  @override
  String get nutritionFat => 'Grasa (g)';

  @override
  String get nutritionFiber => 'Fibra (g)';

  @override
  String get nutritionSugar => 'Azúcar (g)';

  @override
  String get nutritionSatFat => 'Grasa sat. (g)';

  @override
  String get nutritionSodium => 'Sodio (mg)';

  @override
  String get nutritionEnterNumber => 'Introduce un número';

  @override
  String get nutritionNumberAtLeastZero => 'Debe ser >= 0';

  @override
  String rankingsSaved(String target) {
    return 'Clasificaciones de $target guardadas';
  }

  @override
  String get rankingsSave => 'Guardar clasificaciones';

  @override
  String rankingsTitle(String target) {
    return 'Clasificaciones de $target';
  }

  @override
  String rankingsHero(String target) {
    return 'Arrastra $target al orden que quieres que el entrenamiento generado prefiera.';
  }

  @override
  String get rankingsNoBodyParts => 'No hay partes corporales definidas';

  @override
  String get rankingsNoMuscles => 'No hay músculos definidos';

  @override
  String rankingsLoadError(String target, String error) {
    return 'No se pudo cargar $target: $error';
  }

  @override
  String rankingsSaveError(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get rankingsRank => 'Rango';

  @override
  String get mappingTitle => 'Mapeo anatómico';

  @override
  String get mappingHero => 'Conecta músculos a partes corporales para que los mapas de calor, análisis y entrenamientos generados coincidan.';

  @override
  String get mappingSaved => 'Mapeos guardados';

  @override
  String mappingSaveFailed(String error) {
    return 'No se pudo guardar: $error';
  }

  @override
  String get mappingSelectedBodyPart => 'Parte corporal seleccionada';

  @override
  String get mappingBodyPart => 'Parte corporal';

  @override
  String get mappingChooseLinkedMuscles => 'Elegir músculos vinculados';

  @override
  String get mappingLinkedMuscles => 'Músculos vinculados';

  @override
  String get mappingChooseLinkedSubtitle => 'Selecciona cada músculo que pertenece a esta parte corporal.';

  @override
  String mappingLinkedCount(int count) {
    return '$count músculos vinculados actualmente.';
  }

  @override
  String get mappingNoMuscles => 'No hay músculos definidos.';

  @override
  String get mappingNoLinkedMuscles => 'Aún no hay músculos vinculados. Toca Editar para añadir algunos.';

  @override
  String get volumeMaintenance => 'Mantenimiento';

  @override
  String get volumeMinEffective => 'Mínimo efectivo';

  @override
  String get volumeMaxAdaptive => 'Máximo adaptable';

  @override
  String get volumeMaxRecoverable => 'Máximo recuperable';

  @override
  String volumeLoadBodyPartFailed(String error) {
    return 'No se pudieron cargar los límites de partes corporales: $error';
  }

  @override
  String volumeLoadMuscleFailed(String error) {
    return 'No se pudieron cargar los límites musculares: $error';
  }

  @override
  String get volumeBodyPartSaved => 'Límites de parte corporal guardados';

  @override
  String get volumeMuscleSaved => 'Límites musculares guardados';

  @override
  String get volumeInvalidNumbers => 'Introduce números válidos';

  @override
  String get volumeBodyParts => 'Partes del cuerpo';

  @override
  String get volumeMuscles => 'Músculos';

  @override
  String get volumeBodyPartTitle => 'Volumen de parte corporal';

  @override
  String get volumeBodyPartSubtitle => 'Define rangos semanales objetivo usados por análisis semanales y generación de entrenamientos.';

  @override
  String get volumeMuscleTitle => 'Volumen muscular';

  @override
  String get volumeMuscleSubtitle => 'Ajusta los rangos semanales objetivo para músculos individuales.';

  @override
  String get volumeSelection => 'Selección';

  @override
  String get volumeRecommendedRange => 'Rango recomendado';

  @override
  String get volumeRecommendedRangeSubtitle => 'Los números son unidades de series por semana.';

  @override
  String get volumeSaveBoundaries => 'Guardar límites';

  @override
  String get nutritionDashboardTitle => 'Panel de nutrición';

  @override
  String nutritionDashboardError(String error) {
    return 'No se pudo cargar la nutrición: $error';
  }

  @override
  String get nutritionMenuTitle => 'Menú de nutrición';

  @override
  String get nutritionLogFood => 'Registrar alimento';

  @override
  String get nutritionTrackMeasurement => 'Seguir medición';

  @override
  String get nutritionMeasuredItems => 'Elementos medidos';

  @override
  String get nutritionTodayRecords => 'Registros de hoy';

  @override
  String get nutritionGoalsMenu => 'Objetivos nutricionales';

  @override
  String get measurementWeight => 'Peso';

  @override
  String get measurementHips => 'Caderas';

  @override
  String get measurementShoulders => 'Hombros';

  @override
  String get measurementCalves => 'Pantorrillas';

  @override
  String get measurementTrackNew => 'Seguir una nueva medición';

  @override
  String get barcodeScannerTitle => 'Escanear un código de barras';

  @override
  String get barcodeSwitchCamera => 'Cambiar cámara';

  @override
  String get barcodeTorchOn => 'Linterna encendida';

  @override
  String get barcodeTorchOff => 'Linterna apagada';

  @override
  String get barcodeTorchUnavailable => 'La linterna no está disponible en este dispositivo';

  @override
  String get barcodeAlignHint => 'Alinea el código de barras dentro del marco';

  @override
  String get progressTutorialWorkoutReportTitle => 'Informe de entrenamiento';

  @override
  String get progressTutorialWorkoutReportBody => 'Registra el número de entrenamientos, el tiempo y el volumen en diferentes períodos. Toca una métrica para cambiar el gráfico.';

  @override
  String get progressTutorialExerciseProgressTitle => 'Progreso de ejercicios';

  @override
  String get progressTutorialExerciseProgressBody => 'Sigue tendencias de fuerza de ejercicios seleccionados. Usa la tarjeta de edición para añadir o quitar ejercicios de este panel.';

  @override
  String get progressTutorialHealthTrendsTitle => 'Tendencias de salud';

  @override
  String get progressTutorialHealthTrendsBody => 'Registra aquí el peso corporal y medidas personalizadas, y observa cómo cambian con el tiempo.';

  @override
  String get measurementNewTitle => 'Nueva medición';

  @override
  String get measurementPresets => 'Preajustes';

  @override
  String get measurementCustom => 'Personalizado';

  @override
  String get measurementPresetType => 'Tipo de preajuste';

  @override
  String get measurementVariation => 'Variación';

  @override
  String get measurementWakeUp => 'Despertar';

  @override
  String get measurementBedtime => 'Hora de dormir';

  @override
  String get measurementOverall => 'General';

  @override
  String get measurementValueWeight => 'Peso';

  @override
  String get measurementUnits => 'Unidades';

  @override
  String get measurementFeet => 'Pies';

  @override
  String get measurementInches => 'Pulgadas';

  @override
  String get measurementCentimeters => 'Centímetros';

  @override
  String get measurementWithPump => 'Con congestión';

  @override
  String get measurementWithoutPump => 'Sin congestión';

  @override
  String get measurementName => 'Nombre de la medición';

  @override
  String get measurementNameHint => 'Tamaño de pecho, frecuencia cardíaca en reposo...';

  @override
  String get measurementValue => 'Valor';

  @override
  String get measurementUnit => 'Unidad';

  @override
  String get measurementNote => 'Nota';

  @override
  String get measurementOptional => 'Opcional';

  @override
  String get measurementSaveNew => 'Guardar nueva medición';

  @override
  String get measurementCustomRequired => 'Introduce un nombre, valor y unidad personalizados';

  @override
  String measurementDefinitionNotFound(String name) {
    return 'No se encontró la definición para $name';
  }

  @override
  String get measurementInvalidValue => 'Introduce un valor numérico válido';

  @override
  String get measurementHeight => 'Estatura';

  @override
  String get measurementForearm => 'Antebrazo';

  @override
  String get measurementArm => 'Brazo';

  @override
  String get measurementNeck => 'Cuello';

  @override
  String get measurementChest => 'Pecho';

  @override
  String get measurementWaist => 'Cintura';

  @override
  String get measurementThigh => 'Muslo';

  @override
  String get measurementInstructionsForearm => 'Mide alrededor de la parte más ancha del antebrazo.';

  @override
  String get measurementInstructionsArm => 'Mide alrededor de la parte más ancha del bíceps.';

  @override
  String get measurementInstructionsNeck => 'Mide donde la cinta queda recta alrededor del cuello.';

  @override
  String get measurementInstructionsShoulder => 'Mantén la cinta recta alrededor de los deltoides laterales.';

  @override
  String get measurementInstructionsChest => 'Mide debajo de las axilas y por encima de la línea de los pezones.';

  @override
  String get measurementInstructionsWaist => 'Mide alrededor del ombligo.';

  @override
  String get measurementInstructionsHip => 'Mide alrededor de la parte más ancha de los glúteos.';

  @override
  String get measurementInstructionsThigh => 'Mide alrededor de la parte más ancha del muslo.';

  @override
  String get measurementInstructionsCalf => 'Mide alrededor de la parte más ancha de la pantorrilla.';

  @override
  String get nutritionCaloriesLabel => 'Calorías';

  @override
  String get nutritionFatLabel => 'Grasa';

  @override
  String get nutritionProteinLabel => 'Proteína';

  @override
  String get nutritionCarbsLabel => 'Carbohidratos';

  @override
  String nutritionMacroSummary(int calories, int protein, int carbs, int fat) {
    return '$calories kcal | P $protein g | C $carbs g | G $fat g';
  }

  @override
  String get nutritionEditEntry => 'Editar entrada';

  @override
  String get nutritionEditNotAvailable => 'Aún no está disponible la edición de entradas';

  @override
  String get nutritionEntryDeleted => 'Entrada eliminada';

  @override
  String get gymProfileEditTitle => 'Editar perfil de gimnasio';

  @override
  String get gymProfileNewTitle => 'Nuevo perfil de gimnasio';

  @override
  String get gymProfileTutorialSpaceTitle => 'Espacio de entrenamiento';

  @override
  String get gymProfileTutorialSpaceBody => 'Nombra este perfil según donde entrenas, como gimnasio en casa, gimnasio comercial o configuración de viaje.';

  @override
  String get gymProfileTutorialFindTitle => 'Buscar equipo';

  @override
  String get gymProfileTutorialFindBody => 'Usa la búsqueda cuando la lista de equipo sea larga y quieras llegar rápidamente a un elemento.';

  @override
  String get gymProfileTutorialAvailableTitle => 'Equipo disponible';

  @override
  String get gymProfileTutorialAvailableBody => 'Selecciona lo que tiene este espacio. Los planes generados y cambios usan esto para evitar ejercicios no disponibles.';

  @override
  String get gymProfileTutorialSaveTitle => 'Guardar perfil';

  @override
  String get gymProfileTutorialSaveBody => 'Guardar almacena el perfil y el equipo. Cancelar pregunta antes de descartar cambios sin guardar.';

  @override
  String get gymProfileSaveChangesTitle => '¿Guardar cambios?';

  @override
  String get gymProfileSaveChangesBody => 'Tienes cambios sin guardar en el perfil de gimnasio. ¿Guardarlos antes de salir?';

  @override
  String get gymProfileKeepEditing => 'Seguir editando';

  @override
  String get gymProfileDiscard => 'Descartar';

  @override
  String get gymProfileSelectEquipment => 'Selecciona al menos un elemento de equipo.';

  @override
  String gymProfileSaveFailed(String error) {
    return 'No se pudo guardar el perfil: $error';
  }

  @override
  String get gymProfileEquipmentHint => 'Elige lo que tiene este gimnasio para que los planes generados solo usen equipo disponible.';

  @override
  String get gymProfileSpace => 'Espacio de entrenamiento';

  @override
  String gymProfileEquipmentSelected(int selected, int total) {
    return '$selected de $total opciones de equipo seleccionadas';
  }

  @override
  String get gymProfileName => 'Nombre del perfil';

  @override
  String get gymProfileNameHint => 'Gimnasio en casa, gimnasio comercial, configuración de viaje...';

  @override
  String get gymProfileNameRequired => 'Nombre obligatorio';

  @override
  String get gymProfileFilterEquipment => 'Filtrar equipo por nombre';

  @override
  String get gymProfileEquipment => 'Equipo';

  @override
  String get gymProfileSelectAll => 'Seleccionar todo';

  @override
  String get gymProfileClear => 'Borrar';

  @override
  String gymProfileSelectedCount(int selected, int total) {
    return '$selected/$total seleccionados';
  }

  @override
  String get gymProfileSave => 'Guardar perfil';

  @override
  String get gymProfileSaving => 'Guardando...';

  @override
  String gymProfileNoEquipmentMatch(String query) {
    return 'Ningún equipo coincide con \"$query\".';
  }

  @override
  String get equipmentCategoryBasics => 'Básicos';

  @override
  String get equipmentCategoryFreeWeights => 'Pesas libres';

  @override
  String get equipmentCategoryBenchesRacks => 'Bancos y racks';

  @override
  String get equipmentCategoryCableAttachments => 'Cables y accesorios';

  @override
  String get equipmentCategoryMachines => 'Máquinas';

  @override
  String get equipmentCategoryOther => 'Otro equipo';

  @override
  String get equipmentNoRequirement => 'Sin equipo obligatorio';

  @override
  String get equipmentBodyweightSupport => 'Soporte para movimientos de peso corporal';

  @override
  String get equipmentMachineBased => 'Movimiento basado en máquina';

  @override
  String get equipmentCableAccessory => 'Accesorio de estación de cable';

  @override
  String get equipmentBenchRackSetup => 'Configuración de banco, rack o estación';

  @override
  String get equipmentFreeWeightTraining => 'Entrenamiento con pesas libres';

  @override
  String get equipmentAvailable => 'Equipo disponible';

  @override
  String get foodLoggingTitle => 'Registro de alimentos';

  @override
  String get foodLogTime => 'Hora de registro:';

  @override
  String get foodPortion => 'Porción:';

  @override
  String get foodQuantity => 'Cant.:';

  @override
  String foodGramsPerUnit(int grams) {
    return '$grams g / unidad';
  }

  @override
  String get foodRemove => 'Quitar';

  @override
  String get foodAddAllToDiary => 'Añadir todo al diario';

  @override
  String get foodLogging => 'Registrando...';

  @override
  String get foodTabScan => 'Escanear';

  @override
  String get foodTabSearch => 'Buscar';

  @override
  String get foodTabPlanned => 'Planificado';

  @override
  String get foodTabCustom => 'Personalizado';

  @override
  String get foodSearchHint => 'Buscar un alimento...';

  @override
  String get foodNoRecentRecipes => 'Aún no hay recetas recientes.';

  @override
  String get foodRecentRecipe => 'Receta reciente';

  @override
  String get foodNoFoodsFound => 'No se encontraron alimentos.';

  @override
  String get foodInstantLogAfterScan => 'Registrar inmediatamente tras escanear';

  @override
  String get foodInstantLogAfterScanSubtitle => 'Añade el elemento escaneado de inmediato usando la comida seleccionada.';

  @override
  String get foodOpenCameraScanner => 'Abrir escáner de cámara';

  @override
  String get foodEnterBarcode => 'Introducir código de barras manualmente';

  @override
  String get foodEnterBarcodeHint => 'p. ej., 012345678905';

  @override
  String get foodLogByBarcode => 'Registrar por código de barras';

  @override
  String get foodNoBarcode => 'No se detectó un código de barras válido';

  @override
  String get foodBarcodeLogged => 'Elemento registrado desde código de barras';

  @override
  String foodFailed(String error) {
    return 'Error: $error';
  }

  @override
  String get foodCustomSavedBarcode => 'Alimento personalizado guardado y código de barras vinculado';

  @override
  String get foodFavorites => 'Favoritos';

  @override
  String get foodRecentFoods => 'Alimentos recientes';

  @override
  String get foodStartSearching => 'Empieza a buscar para encontrar alimentos.';

  @override
  String get foodFavorite => 'Favorito';

  @override
  String get foodUnfavorite => 'Quitar de favoritos';

  @override
  String get foodCustomize => 'Personalizar alimento';

  @override
  String get foodEditAndAdd => 'Editar y añadir';

  @override
  String get foodAddOne => 'Añadir 1';

  @override
  String get foodAddNew => 'Añadir nuevo alimento';

  @override
  String get foodCustomSaved => 'Alimento personalizado guardado';

  @override
  String get foodNoteOptional => 'Nota (opcional)';

  @override
  String get foodTagsHint => 'Etiquetas (separadas por comas, p. ej., postentrenamiento, alto en proteína)';

  @override
  String get foodAddToPlate => 'Añadir al plato';

  @override
  String get foodProfileNotReady => 'El perfil aún no está listo.';

  @override
  String get foodItemsLogged => 'Elementos registrados en el diario';

  @override
  String foodLogFailed(String error) {
    return 'No se pudo registrar: $error';
  }

  @override
  String get tutorialSkip => 'Omitir';

  @override
  String get tutorialSkipAll => 'Omitir todos';

  @override
  String get tutorialDone => 'Listo';

  @override
  String get tutorialNext => 'Siguiente';

  @override
  String get tutorialSkipAllTitle => '¿Omitir todos los tutoriales?';

  @override
  String get tutorialSkipAllBody => 'Esto oculta todos los tutoriales guiados. Puedes volver a activarlos en cualquier momento en Ajustes > Tutoriales guiados mediante Restablecer todos los tutoriales.';

  @override
  String get tutorialKeep => 'Mantener tutoriales';

  @override
  String get tutorialSkipEverything => 'Omitir todos';

  @override
  String get flowSelectNode => 'Seleccionar nodo';

  @override
  String get flowSelectMethod => 'Seleccionar método';

  @override
  String get flowAddSuccess => '+ Éxito';

  @override
  String get flowAddFailure => '+ Fallo';

  @override
  String get flowAddMethod => '+ Método';

  @override
  String get flowRemoveMethod => '- Método';

  @override
  String get flowNewEvent => 'Nuevo evento';

  @override
  String get flowEventKey => 'Clave de evento';

  @override
  String get flowEventDisplayLabel => 'Etiqueta de visualización (opcional)';

  @override
  String get flowAddSuccessNode => 'Añadir nodo de éxito';

  @override
  String get flowAddFailureNode => 'Añadir nodo de fallo';

  @override
  String get flowAddEvent => '+ Evento';

  @override
  String get flowSelectEvent => 'Seleccionar evento';

  @override
  String get flowRemoveEvent => 'Eliminar evento';

  @override
  String get drawerNavigation => 'Navegación';

  @override
  String get drawerOptionA => 'Opción A';

  @override
  String get drawerOptionB => 'Opción B';

  @override
  String get drawerOptionC => 'Opción C';

  @override
  String get drawerGymProfiles => 'Perfiles de gimnasio';

  @override
  String drawerSavedSpaces(int count) {
    return '$count espacios guardados';
  }

  @override
  String drawerProfileActive(String name) {
    return '$name está activo';
  }

  @override
  String get drawerActiveProfile => 'Perfil activo';

  @override
  String get drawerTapToSwitch => 'Toca para cambiar';

  @override
  String get drawerNewProfile => 'Nuevo perfil';

  @override
  String get commonAdd => 'Añadir';

  @override
  String get commonRemove => 'Quitar';

  @override
  String get automaticSaving => 'Guardando...';

  @override
  String get automaticValuesTab => 'Valores';

  @override
  String get automaticMethodsTab => 'Métodos';

  @override
  String get automaticGlobalIncrement => 'Cantidad de incremento global';

  @override
  String get automaticAutoSelect => 'Selección automática';

  @override
  String get automaticManualSelect => 'Selección manual';

  @override
  String get automaticSkipFirstSet => '¿Omitir primera serie?';

  @override
  String automaticSetLabel(int number, String weight, int reps) {
    return 'Serie $number: $weight x $reps';
  }

  @override
  String automaticChildSetLabel(int parent, int child, String weight, int reps) {
    return 'Serie $parent.$child: $weight x $reps';
  }

  @override
  String automaticSaveFailed(String error) {
    return 'No se pudieron guardar los ajustes: $error';
  }

  @override
  String get automaticIncrementWhen => 'Incrementar cuando (reducir en caso contrario):';

  @override
  String get automaticWeightTarget => 'Peso completado >= peso objetivo';

  @override
  String get automaticRepsTarget => 'Repeticiones completadas >= repeticiones objetivo';

  @override
  String get automaticVolumeTarget => 'Volumen completado >= volumen objetivo';

  @override
  String get automaticScopeLabel => 'Los éxitos, fallos y ajustes se cuentan por:';

  @override
  String get automaticWorkoutSession => 'Sesión de entrenamiento';

  @override
  String get automaticPerExercise => 'Por ejercicio';

  @override
  String get automaticPerSet => 'Por serie';

  @override
  String get automaticAdjustScope => 'Ajustar:';

  @override
  String get automaticAdjustOneSet => '1 serie';

  @override
  String get automaticAdjustAllSets => 'Todas las series';

  @override
  String get weightExpandSets => 'Expandir series';

  @override
  String get weightCollapseSets => 'Contraer series';

  @override
  String get weightDetails => 'Detalles';

  @override
  String get weightRemoveExerciseTitle => 'Quitar ejercicio';

  @override
  String get weightRemoveExerciseBody => '¿Seguro que quieres quitar este ejercicio?';

  @override
  String get weightSwapExercise => 'Cambiar ejercicio';

  @override
  String get weightMakeChangeSet => 'Crear ChangeSet';

  @override
  String weightSetLabel(int number) {
    return 'Serie $number';
  }

  @override
  String weightLabel(String unit) {
    return 'Peso ($unit)';
  }

  @override
  String get weightReps => 'Repeticiones';

  @override
  String get weightRemoveSetTitle => 'Quitar serie';

  @override
  String get weightRemoveSetBody => '¿Seguro que quieres quitar esta serie?';

  @override
  String weightChangeSetLabel(int number) {
    return 'CSet $number';
  }

  @override
  String weightShortLabel(String unit) {
    return 'Pes. ($unit)';
  }

  @override
  String get weightRemoveChangeSetTitle => 'Quitar CSet';

  @override
  String get weightRemoveChangeSetBody => '¿Seguro que quieres quitar este CSet?';

  @override
  String get weightAddChangeSet => 'Añadir CSet';

  @override
  String get weightAddSet => 'Añadir serie';

  @override
  String get swapAlreadySelected => 'Ese ejercicio ya está seleccionado.';

  @override
  String get swapNeedsProfileEquipment => 'Ese ejercicio necesita equipo fuera de este perfil.';

  @override
  String swapLoadFailed(Object error) {
    return 'No se pudieron cargar los reemplazos: $error';
  }

  @override
  String get swapCurrent => 'Actual';

  @override
  String get swapReplacement => 'Reemplazo';

  @override
  String get swapConfirm => 'Confirmar cambio';

  @override
  String get swapNoBodypartData => 'No se encontraron datos de partes corporales.';

  @override
  String get swapLoadingSelected => 'Cargando ejercicio seleccionado...';

  @override
  String get swapBrowseCatalog => 'Explorar catálogo de ejercicios';

  @override
  String get swapNoEquipment => 'No hay equipo indicado';

  @override
  String get swapTitle => 'Cambiar ejercicio';

  @override
  String get swapFindingMatches => 'Buscando coincidencias similares de partes corporales y músculos...';

  @override
  String get swapChooseReplacement => 'Elige un reemplazo similar.';

  @override
  String get swapFilterProfileEquipment => 'Filtrar por equipo del perfil';

  @override
  String get swapBodypartsHit => 'Partes corporales trabajadas';

  @override
  String swapMatch(int percent) {
    return '$percent% de coincidencia';
  }

  @override
  String get swapNoReplacements => 'Aún no se encontraron reemplazos similares.';

  @override
  String get swapNoReplacementsBody => 'Este ejercicio puede necesitar más metadatos musculares o de partes corporales antes de poder cambiarse bien.';

  @override
  String get premadePlansTitle => 'Planes prediseñados';

  @override
  String get premadeTutorialLengthTitle => 'Duración del plan';

  @override
  String get premadeTutorialLengthBody => 'Alterna entre versiones de 1 hora y 2 horas. Las versiones largas incluyen más ejercicios y series totales.';

  @override
  String get premadeTutorialEquipmentTitle => 'Equipo del perfil';

  @override
  String get premadeTutorialEquipmentBody => 'Cuando está activado, Tonos cambia ejercicios no disponibles por opciones similares que tu perfil de gimnasio actual puede realizar.';

  @override
  String get premadeTutorialLibraryTitle => 'Biblioteca de planes';

  @override
  String get premadeTutorialLibraryBody => 'Abre una división, previsualiza un plan y añádelo a tus Planes activos para que aparezca en Entrenamiento.';

  @override
  String get premadeSelectProfile => 'Selecciona primero un perfil de gimnasio.';

  @override
  String premadePlanAdded(String name) {
    return '$name añadido a Planes activos.';
  }

  @override
  String premadePlanAddFailed(String name, String error) {
    return 'No se pudo añadir $name: $error';
  }

  @override
  String get premadeDescription => 'Explora rutinas listas para copiar en tus planes.';

  @override
  String get premadeDiscarding => 'Descartando...';

  @override
  String get premadeReviewPlans => 'Revisar planes';

  @override
  String get allocationSaveChanges => 'Guardar cambios';

  @override
  String get allocationSaving => 'Guardando';

  @override
  String get allocationInvalidCredit => 'Introduce un número cero o positivo para cada crédito.';

  @override
  String get allocationSaved => 'Asignación del ejercicio guardada.';

  @override
  String get allocationSaveFailed => 'No se pudo guardar la asignación del ejercicio. Inténtalo de nuevo.';

  @override
  String get allocationSaveOrDiscard => 'Guarda o descarta tus cambios antes de restablecer.';

  @override
  String get allocationTitle => 'Asignación de series del ejercicio';

  @override
  String get allocationSubtitle => 'Revisa cómo las series completadas contribuyen a los músculos objetivo y partes del cuerpo.';

  @override
  String get allocationHowTitle => 'Cómo funciona el crédito de series';

  @override
  String get allocationHowBody => 'Un músculo principal normalmente recibe 1,00 de crédito por una serie completada. Los músculos de apoyo reciben menos crédito. Esto guía los resúmenes anatómicos y recomendaciones, pero nunca cambia las series que registras.';

  @override
  String allocationLoadFailed(String error) {
    return 'No se pudieron cargar los ejercicios. $error';
  }

  @override
  String get allocationNoExercises => 'Aún no hay ejercicios disponibles.';

  @override
  String get allocationSelectedExercise => 'Ejercicio seleccionado';

  @override
  String get allocationMuscleCredit => 'Crédito muscular';

  @override
  String get allocationBodypartCredit => 'Crédito por parte corporal';

  @override
  String get allocationNoTargetMuscles => 'Sin músculos objetivo';

  @override
  String get allocationNoBodypartMapping => 'Sin mapeo de parte corporal';

  @override
  String get allocationReset => 'Restablecer';

  @override
  String get allocationCredit => 'Crédito';

  @override
  String get allocationNoTargetMusclesBody => 'Este ejercicio aún no tiene datos de músculos objetivo.';

  @override
  String get allocationMuscleCreditBody => 'Cambia un valor para crear una asignación personal. Se usa para resúmenes musculares y enfoque corporal derivado.';

  @override
  String get allocationNoBodypartMappingBody => 'Este ejercicio aún no tiene datos de mapeo de parte corporal.';

  @override
  String get allocationBodypartCreditBody => 'Los valores automáticos se derivan de los músculos y el mapeo anatómico. Editar uno crea una asignación directa y personal por parte corporal.';

  @override
  String get healthTrendsTitle => 'Tendencias de salud';

  @override
  String get healthMetric => 'Métrica';

  @override
  String get healthUnableToLoad => 'No se pudieron cargar las mediciones';

  @override
  String get healthNoMeasurements => 'Aún no hay mediciones';

  @override
  String get healthNoMeasurementsBody => 'Crea una métrica para empezar a seguir el progreso.';

  @override
  String get healthCreateMetric => 'Crear métrica';

  @override
  String healthLogMeasurement(String name) {
    return 'Registrar $name';
  }

  @override
  String healthEditMeasurement(String name) {
    return 'Editar $name';
  }

  @override
  String get healthTutorialSummaryTitle => 'Resumen de medición';

  @override
  String get healthTutorialSummaryBody => 'Consulta el último valor, el cambio desde la entrada anterior y cuántos registros existen.';

  @override
  String get healthTutorialChartTitle => 'Gráfico de tendencia';

  @override
  String get healthTutorialChartBody => 'El gráfico muestra cómo cambia esta medición con el tiempo a medida que registras más entradas.';

  @override
  String get healthTutorialEntriesTitle => 'Entradas';

  @override
  String get healthTutorialEntriesBody => 'Toca una entrada para editarla o elimina las que se registraron por error.';

  @override
  String get healthTutorialLogTitle => 'Registrar nueva entrada';

  @override
  String get healthTutorialLogBody => 'Usa este botón cuando quieras añadir un nuevo registro de medición.';

  @override
  String get healthDeleteEntryTitle => '¿Eliminar entrada?';

  @override
  String healthDeleteEntryBody(String value, String date) {
    return 'Se eliminará $value de $date.';
  }

  @override
  String get healthLogEntry => 'Registrar entrada';

  @override
  String healthLoadFailed(String error) {
    return 'No se pudo cargar: $error';
  }

  @override
  String get healthEntries => 'Entradas';

  @override
  String get healthNoEntries => 'Aún no hay entradas';

  @override
  String healthFirstEntry(String name) {
    return 'Registra tu primera medición de $name.';
  }

  @override
  String get workoutReportLoadFailed => 'No se pudo cargar el informe de entrenamiento.';

  @override
  String get workoutReportTitle => 'Informe de entrenamiento';

  @override
  String get workoutReportAdditionalDetails => 'Detalles adicionales';

  @override
  String get recommendedSetsEdit => 'Editar series recomendadas';

  @override
  String get recommendedSetsTitle => 'Series recomendadas';

  @override
  String get recommendedSetsMinimum => 'Mínimo de series recomendadas';

  @override
  String get recommendedSetsMaximum => 'Máximo de series recomendadas';

  @override
  String get recommendedSetsValidNumbers => 'Introduce números de series válidos.';

  @override
  String get recommendedSetsNonNegative => 'El número de series no puede ser negativo.';

  @override
  String get recommendedSetsRange => 'El máximo debe ser al menos el mínimo.';

  @override
  String get workoutReportWorkouts => 'Entrenamientos';

  @override
  String get workoutReportTime => 'Tiempo';

  @override
  String get workoutReportVolume => 'Volumen';

  @override
  String get workoutReportWorkout => 'entrenamiento';

  @override
  String get workoutReportTotal => 'total';

  @override
  String get databaseSettingsTitle => 'Ajustes de base de datos';

  @override
  String get databaseSettingsSubtitle => 'Copias de seguridad, medios en la nube, comprobaciones de estado y exportaciones de desarrollador.';

  @override
  String get databaseBackupRestore => 'Copia de seguridad y restauración';

  @override
  String get databaseBackupRestoreSubtitle => 'Mueve tus datos locales de Tonos de forma segura.';

  @override
  String get databaseExportBackup => 'Exportar copia de seguridad';

  @override
  String get databaseImportBackup => 'Importar copia de seguridad';

  @override
  String get databaseImportBackupSubtitle => 'Reemplaza los datos locales desde un archivo de exportación guardado.';

  @override
  String get databaseHealth => 'Estado';

  @override
  String get databaseHealthSubtitle => 'Un vistazo rápido al tamaño, esquema y estado del índice de búsqueda.';

  @override
  String get databaseCheckingHealth => 'Comprobando estado de la base de datos...';

  @override
  String get databaseCheckingHealthSubtitle => 'Leyendo esquema, tamaño, tablas e índices.';

  @override
  String get databaseHealthFailed => 'Falló la comprobación de estado de la base de datos';

  @override
  String get databaseMaintenance => 'Mantenimiento';

  @override
  String get databaseMaintenanceSubtitle => 'Herramientas seguras para comprobaciones, optimización y limpieza de almacenamiento.';

  @override
  String get databaseRefreshHealth => 'Actualizar estado';

  @override
  String get databaseIntegrityCheck => 'Ejecutar comprobación de integridad';

  @override
  String get databaseIntegrityCheckSubtitle => 'Pide a SQLite que verifique el archivo de base de datos local.';

  @override
  String get databaseOptimize => 'Optimizar base de datos';

  @override
  String get databaseCheckpointWal => 'Punto de control WAL';

  @override
  String get databaseCheckpointWalSubtitle => 'Vuelca el registro de escritura anticipada en el archivo de base de datos.';

  @override
  String get databaseVacuum => 'Vaciar base de datos';

  @override
  String get databaseVacuumSubtitle => 'Recupera espacio libre después de grandes eliminaciones o importaciones.';

  @override
  String get databaseCloudContent => 'Contenido en la nube';

  @override
  String get databaseCloudContentSubtitle => 'Gestiona el almacenamiento de medios de ejercicios, equipo y anatomía.';

  @override
  String get databaseWifiOnly => 'Descargas solo por Wi-Fi';

  @override
  String get databaseWifiOnlySubtitle => 'Las miniaturas y videos nuevos solo se descargan por Wi-Fi. Los medios en caché siguen funcionando sin conexión.';

  @override
  String get databaseSyncExerciseMedia => 'Sincronizar medios de ejercicio remotos';

  @override
  String get databaseSyncSharedMedia => 'Sincronizar medios del catálogo compartido';

  @override
  String get databaseSyncSharedMediaSubtitle => 'Ilustraciones de equipo, partes corporales y músculos.';

  @override
  String get databaseClearMediaCache => 'Borrar caché de medios descargados';

  @override
  String get databaseClearMediaCacheSubtitle => 'Elimina los archivos de medios remotos almacenados en caché de este dispositivo.';

  @override
  String get databaseDefinitionExports => 'Exportaciones de definiciones';

  @override
  String get databaseDefinitionExportsSubtitle => 'Exporta archivos de definición de la aplicación para inspección o herramientas.';

  @override
  String get exerciseEditorTitle => 'Editor de ejercicios';

  @override
  String get exerciseEditorLoadFailed => 'No se pudieron cargar las definiciones de ejercicios.';

  @override
  String get exerciseEditorChoose => 'Elegir ejercicio';

  @override
  String get exerciseEditorEdit => 'Editar definición';

  @override
  String get exerciseEditorCreate => 'Crear ejercicio personalizado';

  @override
  String get exerciseEditorSaveChanges => 'Guardar cambios';

  @override
  String get exerciseEditorSaving => 'Guardando';

  @override
  String get exerciseEditorMuscles => 'Músculos';

  @override
  String get exerciseEditorBodyparts => 'Partes del cuerpo';

  @override
  String get exerciseEditorEquipment => 'Equipo';

  @override
  String get exerciseEditorGuide => 'Guía';

  @override
  String exerciseProgressAlreadyShown(String name) {
    return '$name ya se muestra.';
  }

  @override
  String get exerciseProgressTrendTitle => 'Tendencia de 1RM';

  @override
  String get exerciseProgressTrendBody => 'Este gráfico compara el 1RM real registrado y el 1RM estimado a lo largo del tiempo. Toca los puntos para ver valores exactos.';

  @override
  String get exerciseProgressRecordings => 'Registros';

  @override
  String get exerciseProgressRecordingsBody => 'Cada registro abre el entrenamiento donde ocurrió ese levantamiento para que puedas revisar el contexto completo.';

  @override
  String get exerciseProgressTitle => 'Progreso de 1RM';

  @override
  String get exerciseProgressEmpty => 'Completa este ejercicio para empezar a crear el historial de progreso.';

  @override
  String get exerciseProgressActual => '1RM real';

  @override
  String get exerciseProgressEstimated => '1RM estimado';

  @override
  String get exerciseProgressSessionOpenFailed => 'No se pudo abrir la sesión de entrenamiento.';

  @override
  String get exerciseProgressSessionMissing => 'No se encontró la sesión de entrenamiento.';

  @override
  String exerciseProgressEstimatedValue(String value) {
    return 'Est. $value';
  }

  @override
  String get exerciseProgressNoActual => 'Sin 1RM real';

  @override
  String exerciseProgressActualValue(String value) {
    return 'Real $value';
  }

  @override
  String get musclePercentTitle => '% trabajado por músculo';

  @override
  String musclePercentLoadFailed(String error) {
    return 'No se pudieron cargar las entradas: $error';
  }

  @override
  String musclePercentUpdateFailed(String error) {
    return 'No se pudo actualizar el porcentaje: $error';
  }

  @override
  String musclePercentResetFailed(String error) {
    return 'No se pudo restablecer al valor predeterminado: $error';
  }

  @override
  String musclePercentError(String error) {
    return 'Error: $error';
  }

  @override
  String get musclePercentNoExercises => 'No hay ejercicios definidos';

  @override
  String get musclePercentEmpty => 'No se han definido porcentajes musculares';

  @override
  String get musclePercentLabel => '%';

  @override
  String get musclePercentRevert => 'Volver al valor predeterminado';

  @override
  String get sevenDayFocusTitle => 'Enfoque de 7 días';

  @override
  String get sevenDayFocusLoadFailed => 'No se pudo cargar el enfoque de 7 días';

  @override
  String get sevenDayFocusEmpty => 'Completa entrenamientos para ver tu enfoque semanal.';

  @override
  String get sevenDayFocusMore => 'más';

  @override
  String get pastSessionsWeek => 'Semana';

  @override
  String get pastSessionsMonth => 'Mes';

  @override
  String get pastSessionsYear => 'Año';

  @override
  String get pastSessionsAll => 'Todo';

  @override
  String get pastSessionsShow => 'Mostrar:';

  @override
  String get pastSessionsFullscreen => 'Pantalla completa';

  @override
  String pastSessionsError(String error) {
    return 'Error: $error';
  }

  @override
  String get pastSessionsEmpty => 'Aún no hay sesiones anteriores.';

  @override
  String pastSessionsItem(String date, String duration) {
    return '$date - $duration';
  }

  @override
  String get historySummaryLoadFailed => 'Error al cargar el historial';

  @override
  String get historySummaryWorkouts => 'Entrenamientos';

  @override
  String get historySummaryTotalTime => 'Tiempo total';

  @override
  String get historySummaryTotalVolume => 'Volumen total';

  @override
  String get planCoachSkipGuide => 'Omitir guía';

  @override
  String get planCoachContinue => 'Continuar';

  @override
  String get trainOptimizedSettingsTitle => 'Ajustes de entrenamiento optimizado';

  @override
  String get trainOptimizedSettingsBudgetBody => 'Se usa un presupuesto de 3 minutos por serie más 5 minutos para iniciar cada ejercicio.';

  @override
  String get trainOptimizedSettingsFocusBody => 'Las selecciones de partes corporales solo se aplican al próximo entrenamiento optimizado.';

  @override
  String get trainWorkoutDuration => 'Duración del entrenamiento';

  @override
  String get trainMinutesShort => 'min';

  @override
  String get trainSetsPerExercise => 'Máximo de series por ejercicio';

  @override
  String get trainSetsShort => 'series';

  @override
  String get trainBodypartFocus => 'Enfoque por parte corporal';

  @override
  String get trainBodypartFocusHelp => 'Toca una vez para preferir una parte corporal, otra para evitarla y una tercera para borrarla.';

  @override
  String get trainBodypartsLoadFailed => 'No se pudieron cargar las partes corporales.';

  @override
  String get trainPlanGenerated => 'Plan generado. Abriéndolo ahora.';

  @override
  String trainPlansGenerated(int count) {
    return 'Se generaron $count planes.';
  }

  @override
  String get trainActiveWorkoutKept => 'Ya hay otro entrenamiento activo, por lo que se mantuvo sin cambios.';

  @override
  String get trainMenuTitle => 'Menú de entrenamiento';

  @override
  String get trainExerciseCatalog => 'Catálogo de ejercicios';

  @override
  String get trainMuscleFilter => 'Filtro de músculos';

  @override
  String get trainGymSettings => 'Ajustes de gimnasio y entrenamiento';

  @override
  String get trainTab => 'Entrenamiento';

  @override
  String get trainHistoryTab => 'Historial';

  @override
  String get trainExercisePresets => 'Preajustes de ejercicios';

  @override
  String get trainGeneratePlans => 'Generar planes personalizados';

  @override
  String get trainAddPlan => 'Añadir preajuste manualmente';

  @override
  String get trainNewPlanFirst => 'Nuevo preajuste';

  @override
  String trainNewPlan(int number) {
    return 'Nuevo preajuste $number';
  }

  @override
  String get trainBuildingOptimized => 'Creando entrenamiento optimizado...';

  @override
  String get trainStartOptimized => 'Iniciar entrenamiento optimizado';

  @override
  String get trainNewSession => 'Nueva sesión';

  @override
  String get foodCustomizationTitle => 'Personalizar alimento';

  @override
  String get foodCustomizationEditTitle => 'Editar alimento';

  @override
  String get foodCustomizationName => 'Nombre del alimento';

  @override
  String get foodCustomizationEnterName => 'Introduce un nombre';

  @override
  String get foodCustomizationBrand => 'Marca';

  @override
  String get foodCustomizationFoodPhoto => 'Foto del alimento';

  @override
  String get foodCustomizationLabelPhoto => 'Foto de etiqueta';

  @override
  String get foodCustomizationDensity => 'Densidad (g/mL)';

  @override
  String get foodCustomizationDensityHelp => 'Se usa para convertir porciones basadas en mL (tazas, cucharadas) a gramos para el cálculo de macros.';

  @override
  String get foodCustomizationCalories => 'Calorías (kcal)';

  @override
  String get foodCustomizationMacronutrients => 'Macronutrientes';

  @override
  String get foodCustomizationMicronutrients => 'Micronutrientes';

  @override
  String get foodCustomizationAdditionalComponents => 'Componentes adicionales';

  @override
  String get foodCustomizationPortionInfo => 'Información de porción';

  @override
  String get foodCustomizationBasisPortion => 'Base de porción para los valores nutricionales';

  @override
  String get foodCustomizationUsualPortion => 'Porción habitual que consume el usuario';

  @override
  String get foodCustomizationAddPortion => 'Añadir porción';

  @override
  String get foodCustomizationUnit => 'Unidad';

  @override
  String get foodCustomizationAmount => 'Cantidad';

  @override
  String get foodCustomizationWeight => 'Peso (g)';

  @override
  String get foodCustomizationVolume => 'Volumen (mL)';

  @override
  String get dashboardArchivedPlans => 'Planes archivados';

  @override
  String get dashboardActivePlans => 'Planes activos';

  @override
  String get dashboardManagePlans => 'Gestionar planes';

  @override
  String get dashboardSelectProfilePlans => 'Selecciona un perfil de gimnasio para ver sus planes.';

  @override
  String get dashboardNoArchivedPlans => 'No hay planes archivados para este perfil.';

  @override
  String get dashboardNoActivePlans => 'Aún no hay planes activos. Usa el lápiz para elegir planes.';

  @override
  String dashboardPremadeCount(int count) {
    return 'Hay $count rutinas listas para añadir.';
  }

  @override
  String get dashboardBrowsePremadePlans => 'Explorar planes prediseñados';

  @override
  String get dashboardNewPlanFirst => 'Nuevo plan';

  @override
  String dashboardNewPlan(int number) {
    return 'Nuevo plan $number';
  }

  @override
  String get dashboardPlanTools => 'Herramientas de planes';

  @override
  String get dashboardPlanToolsBody => 'Crea un plan según tus preferencias de entrenamiento o inicia uno vacío.';

  @override
  String get dashboardManual => 'Manual';

  @override
  String get dashboardGenerate => 'Generar';

  @override
  String get dashboardMostUsedExercises => 'Ejercicios más usados';

  @override
  String get dashboardMostUsedExercisesEmpty => 'Completa entrenamientos para ver aquí tus ejercicios más frecuentes.';

  @override
  String premadeDiscardFailed(String error) {
    return 'No se pudieron descartar los planes añadidos: $error';
  }

  @override
  String get premadeEquipmentSelectProfile => 'Selecciona un perfil de gimnasio para adaptar los planes al equipo disponible.';

  @override
  String get premadeEquipmentExact => 'Los planes prediseñados se muestran exactamente como están escritos.';

  @override
  String get premadeEquipmentChecking => 'Comprobando los ejercicios del plan con tu perfil...';

  @override
  String get premadeEquipmentMissing => 'No se encontró equipo de perfil, por lo que los planes prediseñados no cambian.';

  @override
  String premadeEquipmentReplacements(int count) {
    return 'Se cambiarán $count ejercicio(s) no disponibles al añadir los planes.';
  }

  @override
  String get premadeEquipmentFits => 'Los planes ya se ajustan al equipo del perfil actual.';

  @override
  String get premadeOneHour => '1 h';

  @override
  String get premadeTwoHours => '2 h';

  @override
  String premadePlansAvailable(int count) {
    return '$count plan(es) disponibles';
  }

  @override
  String get premadeNoTemplates => 'Aún no hay plantillas de planes';

  @override
  String premadePlansCount(int count) {
    return '$count plan(es)';
  }

  @override
  String get premadeTemplatesLater => 'Las plantillas para esta división se pueden añadir aquí más tarde.';

  @override
  String premadeExerciseCount(int count) {
    return '$count ejercicios';
  }

  @override
  String premadeSetCount(int count) {
    return '$count series';
  }

  @override
  String premadeSwappedCount(int count) {
    return '$count cambiados';
  }

  @override
  String get premadeAdding => 'Añadiendo';

  @override
  String get premadeChecking => 'Comprobando';

  @override
  String get premadeProfileSwap => 'cambio de perfil';

  @override
  String get healthEntryValueUnitRequired => 'Introduce primero un valor y una unidad.';

  @override
  String get healthDefinitionFieldsRequired => 'Introduce un nombre, unidad y valor válidos.';

  @override
  String get healthUnit => 'Unidad';

  @override
  String get healthNote => 'Nota';

  @override
  String get healthOptional => 'Opcional';

  @override
  String get healthMetricName => 'Nombre de la métrica';

  @override
  String get healthMetricNameHint => 'Tamaño de brazo, frecuencia cardíaca en reposo...';

  @override
  String healthUnitHint(String weightUnit) {
    return 'pulg., $weightUnit, %, lpm...';
  }

  @override
  String get healthStartingValue => 'Valor inicial';

  @override
  String get healthCreate => 'Crear';

  @override
  String get exerciseProgressNoRecordings => 'Aún no hay registros';

  @override
  String get exerciseEditorDiscardTitle => '¿Descartar cambios?';

  @override
  String get exerciseEditorDiscardBody => 'Tus cambios aún no se han guardado. Puedes seguir editando o descartarlos.';

  @override
  String get exerciseEditorKeepEditing => 'Seguir editando';

  @override
  String get exerciseEditorDiscard => 'Descartar';

  @override
  String get exerciseEditorAddBodyparts => 'Añadir partes del cuerpo asociadas';

  @override
  String get exerciseEditorAddMuscles => 'Añadir músculos asociados';

  @override
  String get exerciseEditorAddEquipment => 'Añadir equipo';

  @override
  String get databaseClearMediaTitle => '¿Borrar medios descargados?';

  @override
  String get databaseClearMediaBody => 'Esto elimina los medios almacenados en caché de ejercicios, equipo y anatomía. La aplicación puede descargarlos de nuevo cuando sea necesario.';

  @override
  String get databaseClearCache => 'Borrar caché';

  @override
  String get databaseCacheCleared => 'Se borró la caché de medios descargados.';

  @override
  String databaseClearCacheFailed(String error) {
    return 'No se pudo borrar la caché: $error';
  }

  @override
  String get databaseContentEnvironment => 'Entorno de contenido';

  @override
  String get databaseLoadingEnvironment => 'Cargando entorno...';

  @override
  String get databaseChangeEnvironment => 'Cambiar entorno';

  @override
  String get databaseExerciseManifestUrl => 'URL del manifiesto de medios de ejercicios';

  @override
  String get databaseNoExerciseManifestUrl => 'No hay una URL de manifiesto remoto configurada para este entorno.';

  @override
  String get databaseOverrideUrl => 'Reemplazar URL';

  @override
  String get databaseNoManifestSynced => 'No se sincronizó ningún manifiesto';

  @override
  String databaseManifestVersion(int version) {
    return 'Manifiesto v$version';
  }

  @override
  String databaseLastChecked(String date) {
    return 'Última comprobación: $date';
  }

  @override
  String get databaseSharedCatalogMedia => 'Medios de catálogo compartidos';

  @override
  String get databaseSharedMediaNotSynced => 'Aún no sincronizado. Equipo, partes corporales y músculos.';

  @override
  String databaseManifestLastChecked(int version, String date) {
    return 'Manifiesto v$version. Última comprobación: $date';
  }

  @override
  String get databaseSharedManifestUrl => 'URL del manifiesto de medios compartidos';

  @override
  String get databaseNoSharedManifestUrl => 'No hay URL de medios compartidos remotos para este entorno.';

  @override
  String get databaseDownloadedMediaCache => 'Caché de medios descargados';

  @override
  String databaseCacheUsage(int count, String size) {
    return '$count archivos, $size';
  }

  @override
  String get databaseLoadBundledManifest => 'Cargar manifiesto incluido';

  @override
  String get databaseTutorialFilesTitle => 'Archivos de base de datos';

  @override
  String get databaseTutorialFilesBody => 'Exporta una copia de seguridad o importa un archivo de base de datos guardado. Las importaciones requieren una copia primero.';

  @override
  String get databaseTutorialHealthTitle => 'Estado de base de datos';

  @override
  String get databaseTutorialHealthBody => 'Esta tarjeta muestra versión de esquema, tamaño de base de datos, recuento de tablas y estado del índice de búsqueda.';

  @override
  String get databaseTutorialMaintenanceTitle => 'Herramientas de mantenimiento';

  @override
  String get databaseTutorialMaintenanceBody => 'Usa estas acciones para comprobaciones de integridad, optimización, puntos de control WAL o vaciado cuando sea necesario.';

  @override
  String get databaseExportSavedTitle => 'Exportación de base de datos guardada';

  @override
  String get databaseExportSavedBody => 'La exportación de la base de datos se guardó en la ubicación seleccionada.';

  @override
  String databaseImportBlocked(String message) {
    return 'Importación bloqueada: $message';
  }

  @override
  String get databaseImportBackupCanceled => 'Importación cancelada: no se guardó la copia de seguridad.';

  @override
  String get databaseImportSucceededTitle => 'Importación correcta';

  @override
  String databaseImportSucceededBody(String name) {
    return 'Se importó $name. Primero se guardó una copia de seguridad de la base de datos local anterior en la ubicación seleccionada.';
  }

  @override
  String get databaseConfirmImportTitle => 'Confirmar importación';

  @override
  String get databaseConfirmImportBody => 'Esto reemplaza la base de datos local. Primero se escribirá una copia de seguridad de la base de datos actual.';

  @override
  String databaseImportFile(String name) {
    return 'Archivo: $name';
  }

  @override
  String databaseImportTables(int count) {
    return 'Tablas: $count';
  }

  @override
  String databaseImportRows(int count) {
    return 'Filas: $count';
  }

  @override
  String databaseImportSchema(int version) {
    return 'Esquema de exportación: v$version';
  }

  @override
  String get databaseImportLegacyFormat => 'Formato: mapa de tablas heredado';

  @override
  String get databaseImportWarnings => 'Advertencias:';

  @override
  String get databaseBackupAndImport => 'Copia de seguridad e importación';

  @override
  String databaseMaintenanceFailed(String error) {
    return 'Falló el mantenimiento de la base de datos: $error';
  }

  @override
  String get exerciseEditorSaveBeforeAllocation => 'Guarda o cancela los cambios de definición antes de editar el crédito de series.';

  @override
  String exerciseEditorRemoveItemTitle(String type) {
    return '¿Quitar $type?';
  }

  @override
  String exerciseEditorRemoveItemBody(String name) {
    return '¿Quitar \"$name\" de esta definición de ejercicio?';
  }

  @override
  String get exerciseEditorKeep => 'Conservar';

  @override
  String get exerciseEditorMuscleOrderTitle => 'Orden de músculos objetivo';

  @override
  String get exerciseEditorMuscleOrderBody => 'Ordena los músculos según la intensidad con la que el ejercicio los trabaja. Esto ayuda a Tonos a estimar el enfoque anatómico y hacer mejores recomendaciones.';

  @override
  String get exerciseEditorExactSetCredit => 'Crédito exacto de serie';

  @override
  String get exerciseEditorExactSetCreditBody => 'Cambia el crédito preciso que una serie da a cada músculo o parte del cuerpo en Asignación de series del ejercicio.';

  @override
  String get exerciseEditorSetCreditScaling => 'Escalado de crédito de series';

  @override
  String get exerciseEditorSetCreditScalingBody => 'Elige si la valoración de este ejercicio escala el crédito de series.';

  @override
  String get exerciseEditorScaleCreditByRating => 'Escalar crédito por valoración';

  @override
  String get exerciseEditorScaleCreditByRatingBody => 'Aplica la valoración del ejercicio a los totales analíticos de series.';

  @override
  String get exerciseEditorTargetMuscles => 'Músculos objetivo';

  @override
  String get exerciseEditorOrderMusclesHint => 'Usa las flechas para ordenar los músculos según el énfasis objetivo.';

  @override
  String exerciseEditorMusclesAssociated(int count) {
    return '$count músculos asociados actualmente.';
  }

  @override
  String get exerciseEditorNoTargetMuscles => 'Aún no hay músculos objetivo asociados.';

  @override
  String get exerciseEditorAddTargetMuscles => 'Añadir músculos objetivo';

  @override
  String get exerciseEditorMoveUp => 'Mover arriba';

  @override
  String get exerciseEditorMoveDown => 'Mover abajo';

  @override
  String get exerciseEditorRemoveMuscle => 'Quitar músculo';

  @override
  String get exerciseEditorMuscleItem => 'músculo';

  @override
  String get exerciseEditorAssociatedBodyparts => 'Partes del cuerpo asociadas';

  @override
  String get exerciseEditorAssociatedBodypartsBody => 'Estas áreas amplias determinan los mapas de calor corporal, la cobertura semanal y las recomendaciones de entrenamiento según el equipo.';

  @override
  String get exerciseEditorExactBodypartCredit => 'Crédito exacto de parte corporal';

  @override
  String get exerciseEditorExactBodypartCreditBody => 'Usa la asignación de series del ejercicio cuando una serie deba contar como una cantidad parcial específica para una parte del cuerpo.';

  @override
  String get exerciseEditorBodypartsHint => 'Añade cada área corporal amplia que este ejercicio entrena.';

  @override
  String exerciseEditorBodypartsAssociated(int count) {
    return '$count partes del cuerpo asociadas actualmente.';
  }

  @override
  String get exerciseEditorNoBodyparts => 'Aún no hay partes del cuerpo asociadas.';

  @override
  String get exerciseEditorAutomaticPreview => 'Vista previa automática';

  @override
  String get exerciseEditorAutomaticPreviewBody => 'Enfoque actual derivado de la estructura de músculos objetivo.';

  @override
  String get exerciseEditorRemoveBodypart => 'Quitar parte del cuerpo';

  @override
  String get exerciseEditorBodypartItem => 'parte del cuerpo';

  @override
  String get exerciseEditorAvailableEquipment => 'Equipo disponible';

  @override
  String get exerciseEditorAvailableEquipmentBody => 'El equipo asociado determina qué perfiles pueden usar este ejercicio y qué reemplazos puede recomendar Tonos.';

  @override
  String get exerciseEditorEquipmentHint => 'Añade cada elemento necesario para realizar este ejercicio.';

  @override
  String exerciseEditorEquipmentAssociated(int count) {
    return '$count elementos asociados.';
  }

  @override
  String get exerciseEditorNoEquipment => 'Aún no hay equipo asociado.';

  @override
  String get exerciseEditorRemoveEquipment => 'Quitar equipo';

  @override
  String get exerciseEditorEquipmentItem => 'equipo';

  @override
  String get historySummaryAll => 'Todo';

  @override
  String historySummaryDuration(int hours, int minutes) {
    return '${hours}h ${minutes}m';
  }

  @override
  String planCoachStepTitle(int step, int total, String title) {
    return '$step/$total - $title';
  }

  @override
  String get databaseManifestUrlRequired => 'Añade primero una URL válida de manifiesto de medios de ejercicios.';

  @override
  String databaseContentSyncFailed(String error) {
    return 'Falló la sincronización de contenido: $error';
  }

  @override
  String databaseBundledContentSyncFailed(String error) {
    return 'Falló la sincronización del contenido incluido: $error';
  }

  @override
  String get databaseSharedMediaUrlMissing => 'Este entorno de contenido no tiene URL de medios compartidos.';

  @override
  String databaseSharedContentSyncFailed(String error) {
    return 'Falló la sincronización de contenido compartido: $error';
  }

  @override
  String databaseDefinitionExportFailed(String filename, String error) {
    return 'Falló la exportación de $filename: $error';
  }

  @override
  String get databaseExerciseManifestDialogTitle => 'Manifiesto de medios de ejercicios';

  @override
  String get databaseManifestUrl => 'URL del manifiesto';

  @override
  String get databaseClear => 'Borrar';

  @override
  String get databaseNoManifestConfigured => 'Aún no hay URL de manifiesto configurada.';

  @override
  String get databaseUseEnvironment => 'Usar entorno';

  @override
  String get dashboardTargetAnatomy => 'Anatomía objetivo';

  @override
  String get dashboardBodyparts => 'Partes del cuerpo';

  @override
  String get dashboardMuscles => 'Músculos';

  @override
  String get exerciseEditorCreateCustomTitle => 'Crear ejercicio personalizado';

  @override
  String get exerciseEditorCreateCustomBody => 'Crea una definición personalizada de catálogo y añade su anatomía objetivo y orientación antes de guardar.';

  @override
  String get exerciseEditorExerciseName => 'Nombre del ejercicio';

  @override
  String get exerciseEditorNoEquipmentChoice => 'Sin equipo';

  @override
  String get exerciseEditorOpenedMessage => 'Ejercicio abierto. Añade su anatomía objetivo y luego guarda.';

  @override
  String exerciseEditorCreateFailed(String error) {
    return 'No se pudo crear el ejercicio personalizado. $error';
  }

  @override
  String get exerciseEditorWhatChangesTitle => 'Qué cambia esto';

  @override
  String get exerciseEditorWhatChangesBody => 'Usa este editor avanzado para actualizar el nombre de un ejercicio, anatomía objetivo, equipo, guía de forma, valoración y medios de referencia. El crédito exacto por serie se gestiona por separado para mantener la consistencia en la aplicación.';

  @override
  String get exerciseEditorChooseCatalog => 'Elige un ejercicio del catálogo';

  @override
  String get exerciseEditorRating => 'Valoración';

  @override
  String get databaseNever => 'Nunca';

  @override
  String databaseExportDefinition(String filename) {
    return 'Exportar $filename';
  }

  @override
  String get exerciseEditorAddMedia => 'Añadir medios';

  @override
  String get exerciseEditorEditMedia => 'Editar medios';

  @override
  String get exerciseEditorMediaImage => 'Imagen';

  @override
  String get exerciseEditorMediaVideo => 'Video';

  @override
  String get exerciseEditorMediaLink => 'Enlace';

  @override
  String get exerciseEditorMediaType => 'Tipo';

  @override
  String get exerciseEditorMediaTitle => 'Título';

  @override
  String get exerciseEditorMediaTitleHint => 'Etiqueta de visualización opcional';

  @override
  String get exerciseEditorMediaRemoteUrl => 'URL remota';

  @override
  String get exerciseEditorMediaThumbnailUrl => 'URL de miniatura';

  @override
  String get exerciseEditorMediaThumbnailHint => 'URL opcional de vista previa de imagen';

  @override
  String get exerciseEditorSelectBeforeMedia => 'Selecciona un ejercicio existente antes de adjuntar medios.';

  @override
  String get exerciseEditorFormGuide => 'Guía de forma';

  @override
  String get exerciseEditorFormGuideBody => 'Estas notas aparecen en la hoja de detalles del ejercicio para ayudar a las personas a prepararse, realizar y comprender el movimiento de forma segura.';

  @override
  String get exerciseEditorGuidance => 'Orientación';

  @override
  String get exerciseEditorGuidanceEditing => 'Escribe indicaciones claras y prácticas. Los cambios se guardan provisionalmente hasta que los guardes.';

  @override
  String get exerciseEditorGuidanceReadOnly => 'Las instrucciones e indicaciones actuales del ejercicio.';

  @override
  String get exerciseEditorSetUp => 'Preparación';

  @override
  String get exerciseEditorSetUpHint => 'Posición inicial, configuración del equipo y notas de seguridad.';

  @override
  String get exerciseEditorHowToPerform => 'Cómo realizarlo';

  @override
  String get exerciseEditorHowToPerformHint => 'Los pasos clave del movimiento y el rango de movimiento.';

  @override
  String get exerciseEditorCoachingTips => 'Consejos de entrenamiento';

  @override
  String get exerciseEditorCoachingTipsHint => 'Indicaciones útiles, errores comunes y variaciones.';

  @override
  String get exerciseEditorReferenceMedia => 'Medios de referencia';

  @override
  String get exerciseEditorReferenceMediaBody => 'Usa enlaces de medios para material de referencia privado. Los medios gestionados del catálogo se pueden actualizar mediante la canalización de sincronización de contenido.';

  @override
  String get exerciseEditorMediaLinks => 'Enlaces de medios';

  @override
  String get exerciseEditorMediaLinksEditing => 'Añade o actualiza un enlace remoto de imagen, video o referencia.';

  @override
  String exerciseEditorMediaLinksCount(int count) {
    return '$count elemento(s) de medios vinculados actualmente.';
  }

  @override
  String get exerciseEditorNoReferenceMedia => 'Aún no hay medios de referencia vinculados.';

  @override
  String get exerciseEditorAddMediaLink => 'Añadir enlace de medios';

  @override
  String get exerciseEditorRemoveMedia => 'Quitar medios';

  @override
  String get exerciseEditorMediaLinkItem => 'enlace de medios';

  @override
  String exerciseEditorMediaReference(String type) {
    return 'Referencia de $type';
  }

  @override
  String get bengaliBangladeshLanguage => 'Bangla (Bangladés)';

  @override
  String get simplifiedChineseLanguage => 'Chino (simplificado)';

  @override
  String get hindiLanguage => 'Hindi';

  @override
  String get spanishLanguage => 'Español';

  @override
  String get onboardingWeightHistoryTitle => 'Historial de peso';

  @override
  String get onboardingWeightHistorySubtitle => 'Algunos datos ayudan a estimar los objetivos nutricionales de forma más razonable.';

  @override
  String get onboardingPreviouslyHeavier => '¿Alguna vez pesaste 10 lb o más por encima de tu peso actual?';

  @override
  String get onboardingWeightTrendTitle => 'Tendencia actual del peso';

  @override
  String get onboardingWeightTrendGaining => 'Aumentando de peso';

  @override
  String get onboardingWeightTrendLosing => 'Perdiendo peso';

  @override
  String get onboardingWeightTrendMaintaining => 'Manteniendo el peso';

  @override
  String get onboardingNotSure => 'No estoy seguro';

  @override
  String get onboardingBodyFatEstimateTitle => 'Estimación de grasa corporal';

  @override
  String get onboardingBodyFatEstimateSubtitle => 'Elige la estimación visual más cercana. No es necesario que sea exacta.';

  @override
  String get onboardingNutritionPreferencesTitle => 'Preferencias nutricionales';

  @override
  String get onboardingNutritionPreferencesSubtitle => 'Estas preferencias orientan las sugerencias nutricionales después de la configuración.';

  @override
  String get onboardingPreferredDiet => 'Dieta preferida';

  @override
  String get onboardingDietBalanced => 'Equilibrada';

  @override
  String get onboardingDietLowFat => 'Baja en grasa';

  @override
  String get onboardingDietLowCarb => 'Baja en carbohidratos';

  @override
  String get onboardingDietKeto => 'Keto';

  @override
  String get onboardingCalorieFloor => 'Mínimo de calorías';

  @override
  String get onboardingCalorieFloorHint => 'Mínimo diario de kcal';

  @override
  String get onboardingTrainingDuringProgram => 'Entrenamiento durante el programa';

  @override
  String get onboardingTrainingNone => 'Ninguno';

  @override
  String get onboardingTrainingLifting => 'Fuerza';

  @override
  String get onboardingTrainingCardio => 'Cardio';

  @override
  String get onboardingTrainingLiftingAndCardio => 'Fuerza y cardio';

  @override
  String get onboardingProteinPreference => 'Ingesta de proteína preferida';

  @override
  String get onboardingProteinLow => 'Baja';

  @override
  String get onboardingProteinModerate => 'Moderada';

  @override
  String get onboardingProteinHigh => 'Alta';

  @override
  String get onboardingProteinVeryHigh => 'Muy alta';

  @override
  String get onboardingGoalPaceTitle => 'Ritmo del objetivo';

  @override
  String get onboardingGoalPaceSubtitle => 'Previsualiza un peso objetivo y un ritmo semanal.';

  @override
  String get onboardingInitialDailyBudget => 'Presupuesto diario inicial';

  @override
  String get onboardingProjectedEndDate => 'Fecha de finalización prevista';

  @override
  String get onboardingTargetWeight => 'Peso objetivo';

  @override
  String get onboardingTargetGoalRate => 'Ritmo objetivo';

  @override
  String get onboardingPerWeek => 'Por semana';

  @override
  String get onboardingPerMonth => 'Por mes';

  @override
  String get exerciseProgressTrackExercise => 'Seguir un ejercicio';

  @override
  String get exerciseProgressTrackExerciseBody => 'Elige un ejercicio para ver aquí la tendencia de su 1RM.';

  @override
  String get healthCustomMetric => 'Medida personalizada';

  @override
  String get healthLatest => 'Último';

  @override
  String get healthNoEntry => 'Sin registros';

  @override
  String get healthNotTrackedYet => 'Aún sin seguimiento';

  @override
  String get healthChange => 'Cambio';

  @override
  String get healthNeedTwoEntries => 'Se necesitan 2 registros';

  @override
  String get healthVersusPrevious => 'Frente al anterior';

  @override
  String get healthRecords => 'Registros';

  @override
  String get presetEstimatedTime => 'Tiempo estimado';

  @override
  String get presetNoFocusData => 'Aún no hay datos de enfoque.';

  @override
  String get presetFocusPreviewHelp => 'Añade ejercicios con peso y datos de partes del cuerpo para previsualizar el enfoque del plan.';

  @override
  String get dashboardReorderHelp => 'Arrastra las secciones al orden que mejor te funcione.';

  @override
  String get exerciseEditorCachedLocally => 'Guardado en caché local';

  @override
  String databaseExerciseMediaSyncSuccess(int count, int version) {
    return 'Se sincronizaron $count elementos multimedia de ejercicios (v$version).';
  }

  @override
  String databaseBundledManifestLoaded(int version) {
    return 'Se cargó el manifiesto multimedia de ejercicios incluido (v$version).';
  }

  @override
  String databaseSharedMediaSyncSuccess(int count, int version) {
    return 'Se sincronizaron $count elementos multimedia de equipo y anatomía (v$version).';
  }

  @override
  String get databaseHealthSchema => 'Esquema';

  @override
  String databaseHealthSchemaValue(int current, int target) {
    return 'v$current / objetivo v$target';
  }

  @override
  String get databaseHealthSize => 'Tamaño';

  @override
  String get databaseHealthJournal => 'Diario';

  @override
  String get databaseHealthTables => 'Tablas';

  @override
  String databaseHealthTablesValue(int tables, int indexes, int triggers) {
    return '$tables tablas, $indexes índices, $triggers activadores';
  }

  @override
  String get databaseHealthFoodSearch => 'Búsqueda de alimentos';

  @override
  String databaseHealthFoodSearchValue(int foods, int rows) {
    return '$foods alimentos, $rows filas FTS';
  }

  @override
  String get databaseHealthPath => 'Ruta';

  @override
  String get dashboardWorkoutInProgress => 'Entrenamiento en curso';

  @override
  String get dashboardNoSavedPlans => 'Aún no hay planes guardados para este perfil de gimnasio.';

  @override
  String get exerciseProgressOneRepMax => 'Máximo de 1 repetición';

  @override
  String get exerciseProgressEstimatedOneRepMax => '1RM estimado';

  @override
  String get onboardingPageWeight => 'Peso';

  @override
  String get onboardingPageBodyFat => 'Grasa corporal';

  @override
  String get onboardingPageNutrition => 'Nutrición';

  @override
  String get onboardingPageGoal => 'Objetivo';

  @override
  String dashboardRecordsThisWeek(int count, int total) {
    return '$count/$total esta semana';
  }

  @override
  String dashboardRecordsAllTime(int count) {
    return '$count en total';
  }

  @override
  String get dashboardVisualBodyFat => 'Grasa corporal visual';

  @override
  String get dashboardNewMetric => 'Nueva medida';

  @override
  String get dashboardCurrentMetrics => 'Medidas actuales';

  @override
  String get workoutReportDay => 'día';

  @override
  String get workoutReportDays => 'días';

  @override
  String get workoutReportWeek => 'semana';

  @override
  String get workoutReportMonth => 'mes';

  @override
  String workoutReportAveragePer(String period) {
    return 'Prom. / $period';
  }

  @override
  String get workoutReportWorkoutsLowercase => 'entrenamientos';

  @override
  String get workoutReportLongestStreak => 'Racha más larga';

  @override
  String get workoutReportMostActive => 'Más activo';

  @override
  String get workoutReportNoSessions => 'sin sesiones';

  @override
  String get workoutReportWeekday => 'día de la semana';

  @override
  String workoutReportMetricSemantics(String label) {
    return 'Métrica de informe $label';
  }

  @override
  String workoutReportUnitLogged(String unit) {
    return '$unit registradas';
  }

  @override
  String workoutReportUnitOnDate(String unit, String date) {
    return '$unit el $date';
  }

  @override
  String get profileDiagnosticsTitle => 'Diagnóstico y privacidad';

  @override
  String get profileDiagnosticsSubtitle => 'Versión, consentimiento de informes, historial de sincronización y eliminación de datos.';

  @override
  String get diagnosticsTitle => 'Diagnóstico y privacidad';

  @override
  String get diagnosticsSubtitle => 'Comprende y controla el diagnóstico de producción.';

  @override
  String get diagnosticsAppSection => 'Información de la aplicación';

  @override
  String get diagnosticsAppSectionSubtitle => 'Útil al informar de un problema.';

  @override
  String get diagnosticsVersion => 'Versión y compilación';

  @override
  String get diagnosticsLoading => 'Cargando...';

  @override
  String get diagnosticsUnavailable => 'No disponible';

  @override
  String get diagnosticsCrashSection => 'Diagnósticos anónimos';

  @override
  String get diagnosticsCrashSectionSubtitle => 'Informes opcionales y categóricos sobre fallos de la aplicación y sincronización de medios.';

  @override
  String get diagnosticsCrashReporting => 'Compartir diagnósticos anónimos';

  @override
  String get diagnosticsCrashUnavailable => 'No está configurado en esta compilación. No se pueden compartir diagnósticos anónimos.';

  @override
  String get diagnosticsCrashEnabledBody => 'Activado con tu consentimiento. Al desactivarlo se solicita eliminar los informes conservados por Tonos.';

  @override
  String get diagnosticsCrashDisabledBody => 'Desactivado de forma predeterminada. Actívalo solo si quieres ayudar a diagnosticar problemas de la versión.';

  @override
  String get diagnosticsPrivacyPromiseTitle => 'Privacidad desde el diseño';

  @override
  String get diagnosticsPrivacyPromiseBody => 'Los informes solo contienen la versión y compilación de la aplicación, plataforma, categoría aprobada, resultado e intervalos generales. Nunca incluyen mensajes de error, seguimientos de pila, nombres, datos de salud, contenido de base de datos, capturas, direcciones de red, trazas ni analíticas.';

  @override
  String get diagnosticsSyncSection => 'Historial de sincronización';

  @override
  String get diagnosticsSyncSectionSubtitle => 'Los 30 resultados más recientes de manifiestos multimedia se guardan solo en este dispositivo.';

  @override
  String get diagnosticsNoSyncEvents => 'Aún no hay diagnósticos de sincronización';

  @override
  String get diagnosticsNoSyncEventsBody => 'Los resultados aparecerán aquí sin URL ni datos personales.';

  @override
  String get diagnosticsClearHistory => 'Borrar historial de sincronización';

  @override
  String get diagnosticsClearHistoryBody => 'Elimina todas las entradas de diagnóstico guardadas localmente.';

  @override
  String get diagnosticsHistoryCleared => 'Se borró el historial de diagnóstico.';

  @override
  String get diagnosticsExerciseMedia => 'Contenido de ejercicios';

  @override
  String get diagnosticsSharedMedia => 'Contenido compartido';

  @override
  String get diagnosticsRemoteSource => 'Remoto';

  @override
  String get diagnosticsBundledSource => 'Incluido';

  @override
  String get diagnosticsSyncSucceeded => 'Correcto';

  @override
  String get diagnosticsSyncFailed => 'Falló';

  @override
  String diagnosticsSyncEventTitle(String operation, String outcome) {
    return '$operation: $outcome';
  }

  @override
  String diagnosticsSyncEventDetails(String source, String timestamp, int duration, String version, String items) {
    return '$source • $timestamp • $duration ms • manifiesto $version • $items elementos';
  }

  @override
  String get diagnosticsPrivacySection => 'Tus datos';

  @override
  String get diagnosticsPrivacySectionSubtitle => 'Almacenamiento local, conservación y eliminación.';

  @override
  String get diagnosticsLocalDataTitle => 'Los datos de actividad permanecen locales';

  @override
  String get diagnosticsLocalDataBody => 'Los entrenamientos, la nutrición, las medidas corporales y el perfil permanecen en la base de datos de este dispositivo, salvo que exportes una copia de seguridad.';

  @override
  String get diagnosticsDeletionTitle => 'Eliminar diagnósticos y datos';

  @override
  String get diagnosticsDeletionBody => 'Borra el historial anterior y desactiva los informes. Borra el almacenamiento de Tonos en los ajustes del dispositivo o desinstala Tonos para eliminar la base de datos local y las cachés. Para eliminar un informe ya enviado, contacta con el desarrollador e incluye los datos del evento que tengas.';

  @override
  String get diagnosticsSendTestReport => 'Enviar un evento de diagnóstico controlado';

  @override
  String get diagnosticsSendTestReportBody => 'Disponible solo en una compilación habilitada explícitamente para pruebas. Envía un evento fijo de la lista permitida.';

  @override
  String get diagnosticsTestReportSent => 'Evento de diagnóstico controlado enviado.';

  @override
  String get diagnosticsTestReportFailed => 'No se pudo enviar el evento de diagnóstico. Comprueba la configuración de la compilación y la conexión.';

  @override
  String get diagnosticsDeleteShared => 'Eliminar diagnósticos compartidos';

  @override
  String get diagnosticsDeleteSharedBody => 'Solicita eliminar los informes que esta instalación puede demostrar que envió. El historial de recuperación del proveedor puede conservar filas eliminadas hasta 30 días.';

  @override
  String get diagnosticsSharedDeleted => 'Se solicitó eliminar los diagnósticos compartidos.';

  @override
  String get diagnosticsSharedDeletionPending => 'Algunas solicitudes de eliminación se reintentarán cuando la aplicación se abra con conexión.';

  @override
  String get workoutDurabilityRestoreWarning => 'Tonos no pudo comprobar si hay un entrenamiento guardado. Reinténtalo antes de iniciar otro entrenamiento.';

  @override
  String get workoutDurabilityDraftSaveWarning => 'La copia de seguridad del entrenamiento no está actualizada. Mantén Tonos abierto y reinténtalo para poder reanudarlo de forma segura.';

  @override
  String get workoutDurabilityProgressionWarning => 'El entrenamiento está guardado, pero la progresión del plan sigue pendiente. Reinténtalo cuando el almacenamiento esté disponible.';

  @override
  String get databaseConfirmExportTitle => '¿Exportar datos privados?';

  @override
  String get databaseConfirmExportBody => 'Esta copia es un archivo JSON sin cifrar que puede contener tus entrenamientos, nutrición, medidas corporales, perfil y preferencias. Guárdala solo en un lugar de confianza.';

  @override
  String get databaseContinueExport => 'Exportar de todos modos';

  @override
  String get databaseExportFailedSafe => 'No se pudo crear la exportación. Tus datos de la aplicación no cambiaron.';

  @override
  String get databaseImportFileTooLarge => 'Esta importación es demasiado grande. Elige una copia de seguridad de menos de 25 MB.';

  @override
  String get databaseImportBlockedSafe => 'No se pudo importar esta copia de seguridad. Tus datos actuales no cambiaron.';

  @override
  String get databaseImportFailedSafe => 'La importación no terminó. Tus datos actuales se mantuvieron seguros.';

  @override
  String get speedDialLogFood => 'Registrar alimento';

  @override
  String get speedDialLogMeasurement => 'Registrar medición';

  @override
  String get healthTapToLog => 'Toca + para registrar';

  @override
  String get healthMetricInvalid => 'Usa un nombre de métrica único y una unidad corta sin espacios.';

  @override
  String get healthMeasurementEntryInvalid => 'Introduce un valor positivo razonable con una unidad compatible.';
}
