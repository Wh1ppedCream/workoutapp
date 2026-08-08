// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String onboardingBodyWeightPerWeek(String percent) {
    return '$percent % du poids corporel/sem.';
  }

  @override
  String get dashboardExerciseFallback => 'Exercice';

  @override
  String dashboardExerciseUsage(String equipment, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '1 fois',
    );
    return '$equipment - $_temp0';
  }

  @override
  String weightCardSetsDone(int completed, int total) {
    return '$completed/$total terminées';
  }

  @override
  String bodyHeatmapSemantics(String bodyPart) {
    return 'Carte thermique du corps pour $bodyPart';
  }

  @override
  String databaseSaveFile(String filename) {
    return 'Enregistrer $filename';
  }

  @override
  String databaseFileSaved(String filename) {
    return '$filename a été enregistré à l’emplacement sélectionné.';
  }

  @override
  String databaseProductionEnvironment(String label) {
    return '$label (production)';
  }

  @override
  String dashboardDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get workoutReportRangeOneWeekShort => '1 sem.';

  @override
  String get workoutReportRangeOneMonthShort => '1 mois';

  @override
  String get workoutReportRangeThreeMonthsShort => '3 mois';

  @override
  String get workoutReportRangeSixMonthsShort => '6 mois';

  @override
  String get workoutReportRangeOneYearShort => '1 an';

  @override
  String get workoutReportRangeAll => 'Tout';

  @override
  String get workoutReportRangeOneWeek => '1 semaine';

  @override
  String get workoutReportRangeOneMonth => '1 mois';

  @override
  String get workoutReportRangeThreeMonths => '3 mois';

  @override
  String get workoutReportRangeSixMonths => '6 mois';

  @override
  String get workoutReportRangeOneYear => '1 an';

  @override
  String workoutReportChartTitle(String metric, String period) {
    return '$metric ($period)';
  }

  @override
  String workoutReportWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entraînements',
      one: '1 entraînement',
      zero: '0 entraînement',
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
      other: '$count heures',
      one: '1 heure',
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
  String get workoutReportNoWorkoutsYet => 'Aucun entraînement pour le moment';

  @override
  String get workoutReportNoTrainingTimeYet => 'Aucun temps d’entraînement pour le moment';

  @override
  String get workoutReportNoVolumeYet => 'Aucun volume enregistré pour le moment';

  @override
  String get workoutReportNoWorkoutsBody => 'Terminez un entraînement pour commencer à créer ce rapport.';

  @override
  String get workoutReportNoTrainingTimeBody => 'Les séances terminées ajouteront automatiquement des minutes ici.';

  @override
  String get workoutReportNoVolumeBody => 'Enregistrez les poids des séries terminées pour créer des tendances de volume.';

  @override
  String get appTitle => 'Tonos';

  @override
  String get uiAppearanceTitle => 'Interface et apparence';

  @override
  String get uiAppearanceSubtitle => 'Contrôlez l’apparence de Tonos et le fonctionnement des onglets de navigation.';

  @override
  String get displaySettingsTitle => 'Affichage';

  @override
  String get displaySettingsSubtitle => 'Préférences visuelles rapides.';

  @override
  String get darkModeTitle => 'Mode sombre';

  @override
  String get darkModeSubtitle => 'Utiliser le thème sombre de l’application.';

  @override
  String get replayOnboardingTitle => 'Revoir la configuration initiale';

  @override
  String get replayOnboardingSubtitle => 'Activez cette option pour recommencer la configuration. Elle se désactive une fois la configuration terminée.';

  @override
  String get weightUnitsTitle => 'Unités de poids';

  @override
  String weightUnitsSubtitle(String unit) {
    return 'Afficher les poids d’entraînement et le volume en $unit.';
  }

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSubtitle => 'Choisissez la langue utilisée par Tonos.';

  @override
  String get systemDefaultLanguage => 'Langue du système';

  @override
  String get englishLanguage => 'English';

  @override
  String get canadianFrenchLanguage => 'Français (Canada)';

  @override
  String get navigationSettingsTitle => 'Navigation';

  @override
  String get navigationSettingsSubtitle => 'Choisissez les onglets de navigation affichés et leur ordre.';

  @override
  String get editBottomTabsTitle => 'Modifier les onglets de navigation';

  @override
  String get editBottomTabsSubtitle => 'Réorganisez les onglets actifs ou masquez ceux que vous n’utilisez pas.';

  @override
  String get displaySettingsTutorialTitle => 'Paramètres d’affichage';

  @override
  String get displaySettingsTutorialBody => 'Contrôlez le mode sombre, la langue et les unités de poids, ou recommencez la configuration initiale.';

  @override
  String get bottomTabsTutorialTitle => 'Onglets de navigation';

  @override
  String get bottomTabsTutorialBody => 'Choisissez les onglets de navigation affichés et modifiez leur ordre.';

  @override
  String get onboardingPageWelcome => 'Bienvenue';

  @override
  String get onboardingPageBasics => 'Renseignements';

  @override
  String get onboardingPageFocus => 'Priorités';

  @override
  String get onboardingPageGymProfile => 'Profil d’entraînement';

  @override
  String get onboardingPageEquipment => 'Équipement';

  @override
  String get onboardingPageWorkoutPlan => 'Plan d’entraînement';

  @override
  String get onboardingPagePlanOverview => 'Aperçu des plans';

  @override
  String get onboardingPageSummary => 'Résumé';

  @override
  String get onboardingPreviousStepTooltip => 'Étape précédente';

  @override
  String onboardingStepProgress(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onboardingFinish => 'Terminer';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingFinishing => 'Finalisation...';

  @override
  String get onboardingFinishSetup => 'Terminer la configuration';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingSkipSetupTitle => 'Passer la configuration?';

  @override
  String get onboardingSkipSetupBody => 'Vous pouvez accéder à l’accueil de l’application maintenant et terminer la configuration plus tard. Vous pouvez aussi relancer la configuration initiale à partir des paramètres.';

  @override
  String get onboardingCancel => 'Annuler';

  @override
  String get onboardingConfirm => 'OK';

  @override
  String onboardingFinishError(String error) {
    return 'Impossible de terminer la configuration : $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Bienvenue dans Tonos';

  @override
  String get onboardingWelcomeSubtitle => 'Une courte configuration permet de personnaliser les entraînements, la nutrition et le suivi des progrès.';

  @override
  String get onboardingLanguageSelectionTitle => 'Choisissez votre langue';

  @override
  String get onboardingLanguageSelectionHelp => 'La configuration se met à jour immédiatement. Vous pourrez modifier ce choix plus tard dans les paramètres.';

  @override
  String get onboardingTrainFeatureTitle => 'Entraînez-vous selon votre profil';

  @override
  String get onboardingTrainFeatureBody => 'Utilisez vos préférences et votre historique pour personnaliser les suggestions d’entraînement.';

  @override
  String get onboardingNutritionFeatureTitle => 'Soutenez vos objectifs nutritionnels';

  @override
  String get onboardingNutritionFeatureBody => 'Choisissez le niveau d’accompagnement nutritionnel que vous souhaitez recevoir.';

  @override
  String get onboardingProgressFeatureTitle => 'Suivez vos progrès';

  @override
  String get onboardingProgressFeatureBody => 'Conservez vos données d’entraînement et de nutrition au même endroit au fil du temps.';

  @override
  String get onboardingBasicsTitle => 'Parlez-nous de vous';

  @override
  String get onboardingBasicsSubtitle => 'Ces renseignements sont facultatifs, mais ils améliorent les calculs futurs.';

  @override
  String get onboardingNameLabel => 'Nom';

  @override
  String get onboardingNameHint => 'Entrez votre nom';

  @override
  String get onboardingGenderLabel => 'Genre';

  @override
  String get onboardingGenderMale => 'Homme';

  @override
  String get onboardingGenderFemale => 'Femme';

  @override
  String get onboardingGenderOther => 'Autre';

  @override
  String get onboardingGenderPreferNotToSay => 'Préfère ne pas répondre';

  @override
  String get onboardingDateOfBirthLabel => 'Date de naissance';

  @override
  String get onboardingSelectDate => 'Choisir une date';

  @override
  String get onboardingHeightLabel => 'Taille';

  @override
  String get onboardingHeightHint => 'p. ex. 5 pi 10 po ou 178 cm';

  @override
  String get onboardingWorkoutWeightUnits => 'Unités de poids d’entraînement';

  @override
  String get onboardingCurrentWeightLabel => 'Poids actuel';

  @override
  String get onboardingWeightHintPounds => 'p. ex. 160';

  @override
  String get onboardingWeightHintKilograms => 'p. ex. 72';

  @override
  String get onboardingPounds => 'Livres';

  @override
  String get onboardingKilograms => 'Kilogrammes';

  @override
  String get onboardingFocusTitle => 'Que doit personnaliser Tonos?';

  @override
  String get onboardingFocusSubtitle => 'Choisissez ce que vous souhaitez configurer maintenant. Vous pourrez modifier ces choix plus tard.';

  @override
  String get onboardingNutritionDataTitle => 'Données nutritionnelles';

  @override
  String get onboardingNutritionDataPausedBody => 'La configuration nutritionnelle est en pause pendant la refonte de cette section.';

  @override
  String get onboardingLater => 'Plus tard';

  @override
  String get onboardingExerciseDataTitle => 'Données d’entraînement';

  @override
  String get onboardingExerciseDataBody => 'Configurez votre profil d’entraînement et vos premiers plans.';

  @override
  String get onboardingGymSpaceTitle => 'Où vous entraînez-vous?';

  @override
  String get onboardingGymSpaceSubtitle => 'Choisissez un espace de départ. Son équipement orientera les suggestions d’exercices et les entraînements générés.';

  @override
  String get onboardingEquipmentLoadError => 'Impossible de charger l’équipement.';

  @override
  String get onboardingTryAgain => 'Réessayer';

  @override
  String get onboardingGymCustomTitle => 'Espace personnalisé';

  @override
  String get onboardingGymCustomSubtitle => 'Créez votre propre profil en choisissant chaque équipement disponible.';

  @override
  String get onboardingGymCustomDefaultName => 'Espace personnalisé';

  @override
  String get onboardingGymSkipTitle => 'Passer cette étape';

  @override
  String get onboardingGymSkipSubtitle => 'Conservez le profil Général et choisissez votre équipement plus tard.';

  @override
  String get onboardingGymGeneralName => 'Général';

  @override
  String get onboardingGymCommercialTitle => 'Centre d’entraînement';

  @override
  String get onboardingGymCommercialSubtitle => 'Commencez avec tout l’équipement disponible, puis retirez ce que votre centre ne possède pas.';

  @override
  String get onboardingGymCommercialDefaultName => 'Centre d’entraînement';

  @override
  String get onboardingGymHomeTitle => 'Salle d’entraînement maison';

  @override
  String get onboardingGymHomeSubtitle => 'Un espace maison pratique avec des poids libres, des bandes, un banc et de l’équipement au poids du corps.';

  @override
  String get onboardingGymHomeDefaultName => 'Salle d’entraînement maison';

  @override
  String get onboardingGymCalisthenicsTitle => 'Callisthénie';

  @override
  String get onboardingGymCalisthenicsSubtitle => 'De l’équipement axé sur le poids du corps, notamment des barres, des anneaux, des bandes et des accessoires de base.';

  @override
  String get onboardingGymCalisthenicsDefaultName => 'Callisthénie';

  @override
  String get onboardingGymPowerliftingTitle => 'Force athlétique';

  @override
  String get onboardingGymPowerliftingSubtitle => 'Un espace axé sur la barre avec des plaques, une cage de puissance et un banc.';

  @override
  String get onboardingGymPowerliftingDefaultName => 'Force athlétique';

  @override
  String get onboardingGymFreeWeightsTitle => 'Poids libres';

  @override
  String get onboardingGymFreeWeightsSubtitle => 'Des haltères, des kettlebells, des plaques, un banc et des mouvements au poids du corps.';

  @override
  String get onboardingGymFreeWeightsDefaultName => 'Poids libres';

  @override
  String get onboardingReviewWorkoutSpaceTitle => 'Vérifiez votre espace d’entraînement';

  @override
  String get onboardingReviewWorkoutSpaceSubtitle => 'Renommez le profil ou modifiez son équipement avant que Tonos le crée.';

  @override
  String get onboardingProfileNameLabel => 'Nom du profil';

  @override
  String get onboardingIncludedEquipmentTitle => 'Équipement inclus';

  @override
  String get onboardingIncludedEquipmentBody => 'Seuls les exercices compatibles avec cet équipement seront suggérés lorsque ce profil est actif.';

  @override
  String get onboardingNoEquipmentSelected => 'Aucun équipement sélectionné.';

  @override
  String get onboardingReset => 'Réinitialiser';

  @override
  String get onboardingEditProfile => 'Modifier le profil';

  @override
  String get onboardingEditWorkoutSpaceTitle => 'Modifier l’espace d’entraînement';

  @override
  String get onboardingSelectEquipmentError => 'Sélectionnez au moins un équipement.';

  @override
  String get onboardingWorkoutPlanTitle => 'Configurez votre plan d’entraînement';

  @override
  String get onboardingWorkoutPlanSubtitle => 'Choisissez comment Tonos doit préparer vos premiers plans. Vous pourrez toujours ajouter, archiver ou modifier des plans plus tard.';

  @override
  String get onboardingManualPlanTitle => 'Créer vos propres plans manuellement';

  @override
  String get onboardingManualPlanSubtitle => 'Commencez avec un plan vide, puis ajoutez vous-même les exercices et les séries.';

  @override
  String get onboardingPremadePlanTitle => 'Utiliser des plans d’entraînement prédéfinis';

  @override
  String get onboardingPremadePlanSubtitle => 'Parcourez les plans intégrés pour le corps entier, le haut et le bas du corps, la séquence pousser-tirer-jambes et les divisions par partie du corps.';

  @override
  String get onboardingGeneratePlanTitle => 'Générer des plans d’entraînement';

  @override
  String get onboardingGeneratePlanSubtitle => 'Répondez à quelques questions et laissez Tonos générer un plan personnalisé pour votre profil.';

  @override
  String get onboardingSkipPlanTitle => 'Passer cette étape';

  @override
  String get onboardingSkipPlanSubtitle => 'Commencez sans ajouter de plans. Vous pourrez les configurer plus tard dans Entraînement.';

  @override
  String onboardingPlansAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans ont été ajoutés aux plans actifs.',
      one: '$count plan a été ajouté aux plans actifs.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingReviewPlansTitle => 'Vérifiez vos plans';

  @override
  String get onboardingReviewPlansSubtitle => 'Ces plans ont été ajoutés à vos plans actifs. Ouvrez un plan pour le consulter ou le modifier avant de continuer.';

  @override
  String onboardingPlansReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans sont prêts dans les plans actifs.',
      one: '$count plan est prêt dans les plans actifs.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanOverviewLoadError => 'Impossible de charger l’aperçu des plans pour le moment.';

  @override
  String get onboardingNoAddedPlans => 'Aucun plan ajouté n’a été trouvé. Revenez en arrière pour ajouter des plans ou passez cette étape.';

  @override
  String get onboardingReadyTitle => 'Prêt à commencer';

  @override
  String get onboardingReadySubtitle => 'Vérifiez votre configuration, puis terminez pour accéder à Tonos.';

  @override
  String get onboardingSummaryName => 'Nom';

  @override
  String get onboardingSummaryGender => 'Genre';

  @override
  String get onboardingSummaryDateOfBirth => 'Date de naissance';

  @override
  String get onboardingSummaryHeight => 'Taille';

  @override
  String get onboardingSummaryWeight => 'Poids';

  @override
  String get onboardingSummaryWorkoutUnits => 'Unités d’entraînement';

  @override
  String get onboardingSummaryIncluded => 'Configuration incluse';

  @override
  String get onboardingSummaryGymProfile => 'Profil d’entraînement';

  @override
  String get onboardingSummaryEquipment => 'Équipement';

  @override
  String get onboardingSummaryWorkoutPlans => 'Plans d’entraînement';

  @override
  String get onboardingSummaryProfileSection => 'Profil';

  @override
  String get onboardingSummaryTrainingSection => 'Configuration de l’entraînement';

  @override
  String get onboardingSummaryNutritionSection => 'Préférences nutritionnelles';

  @override
  String get onboardingSummaryDiet => 'Régime';

  @override
  String get onboardingSummaryProteinPreference => 'Préférence de protéines';

  @override
  String get onboardingIncludedNutrition => 'Configuration nutritionnelle';

  @override
  String get onboardingIncludedExercise => 'Configuration des entraînements';

  @override
  String get onboardingIncludedBasicOnly => 'Profil de base seulement';

  @override
  String onboardingEquipmentSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '$count sélectionné',
    );
    return '$_temp0';
  }

  @override
  String onboardingPlanSummaryAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans ajoutés',
      one: '$count plan ajouté',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanSummaryPremade => 'Plans prédéfinis sélectionnés';

  @override
  String get onboardingPlanSummaryGenerated => 'Génération sélectionnée';

  @override
  String get onboardingPlanSummarySkipped => 'Étape passée';

  @override
  String get onboardingPlanSummaryManual => 'Création manuelle sélectionnée';

  @override
  String get onboardingPlanSummaryNotSelected => 'Aucune option sélectionnée';

  @override
  String get onboardingNewPlan => 'Nouveau plan';

  @override
  String onboardingNumberedNewPlan(int number) {
    return 'Nouveau plan $number';
  }

  @override
  String get tabTrain => 'Entraînement';

  @override
  String get tabTrainSecondary => 'Entraînement 2';

  @override
  String get tabCatalog => 'Catalogue';

  @override
  String get tabLogbook => 'Journal';

  @override
  String get tabProgress => 'Progrès';

  @override
  String get tabProfile => 'Profil';

  @override
  String get tabDashboard => 'Tableau de bord';

  @override
  String get tabNutrition => 'Nutrition';

  @override
  String get tabNutritionLog => 'Journal nutritionnel';

  @override
  String get tabCombinedHistory => 'Historique combiné';

  @override
  String get tabFormAndPosing => 'Forme et poses';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileSubtitle => 'Personnalisez Tonos, gérez les réglages d’entraînement et gardez vos données en bon état.';

  @override
  String get profileAccountSectionTitle => 'Compte';

  @override
  String get profileAccountSectionSubtitle => 'Votre identité et l’apparence générale de l’application.';

  @override
  String get profileUserInformationTitle => 'Renseignements personnels';

  @override
  String get profileUserInformationSubtitle => 'Nom, données corporelles et profil d’activité.';

  @override
  String get profileUiAppearanceTitle => 'Interface et apparence';

  @override
  String get profileUiAppearanceSubtitle => 'Thème, configuration initiale et onglets de navigation.';

  @override
  String get profileGuidedTutorialsTitle => 'Tutoriels guidés';

  @override
  String get profileGuidedTutorialsSubtitle => 'Rejouez les visites guidées et réinitialisez l’aide.';

  @override
  String get profileTrainingSectionTitle => 'Entraînement';

  @override
  String get profileTrainingSectionSubtitle => 'Valeurs par défaut des exercices et réglages liés aux progrès.';

  @override
  String get profileGymWorkoutSettingsTitle => 'Réglages du gym et des entraînements';

  @override
  String get profileGymWorkoutSettingsSubtitle => 'Génération d’entraînements, classements, flux et logique d’équipement.';

  @override
  String get profileProgressSettingsTitle => 'Réglages des progrès';

  @override
  String get profileProgressSettingsSubtitle => 'Configuration du suivi des mesures et des tendances.';

  @override
  String get profileDataSectionTitle => 'Données';

  @override
  String get profileDataSectionSubtitle => 'Outils de base de données, exportations, importations et entretien.';

  @override
  String get profileDatabaseSettingsTitle => 'Réglages de la base de données';

  @override
  String get profileDatabaseSettingsSubtitle => 'Importation, exportation, vérifications et outils d’entretien.';

  @override
  String get profileNutritionSectionTitle => 'Nutrition';

  @override
  String get profileNutritionSectionSubtitle => 'Les réglages nutritionnels sont en pause pendant la refonte de cette section.';

  @override
  String get profileDietNutritionSettingsTitle => 'Réglages de l’alimentation et de la nutrition';

  @override
  String get profileDietNutritionSettingsSubtitle => 'Les objectifs et préférences nutritionnels reviendront plus tard.';

  @override
  String get profileLater => 'Plus tard';

  @override
  String get profileAccountTutorialTitle => 'Réglages du compte';

  @override
  String get profileAccountTutorialBody => 'Modifiez vos renseignements personnels, vos préférences d’affichage, vos unités de poids, la configuration initiale, les onglets de navigation et les tutoriels guidés.';

  @override
  String get profileTrainingTutorialTitle => 'Réglages d’entraînement';

  @override
  String get profileTrainingTutorialBody => 'Gérez les profils de gym, les règles de génération, les classements des parties du corps, les réglages de progression et les autres valeurs d’entraînement par défaut.';

  @override
  String get profileDataTutorialTitle => 'Outils de données';

  @override
  String get profileDataTutorialBody => 'Les réglages de la base de données permettent d’exporter, d’importer, de vérifier et d’entretenir vos données d’entraînement locales.';

  @override
  String catalogLoadError(String error) {
    return 'Impossible de charger le catalogue : $error';
  }

  @override
  String get catalogNoData => 'Aucune donnée de catalogue pour le moment.';

  @override
  String get catalogExerciseTitle => 'Catalogue d’exercices';

  @override
  String get catalogMostUsedExercises => 'Exercices les plus utilisés';

  @override
  String get catalogNoExerciseHistory => 'Terminez des entraînements pour voir vos exercices les plus fréquents ici.';

  @override
  String get catalogTargetAnatomyTitle => 'Anatomie ciblée';

  @override
  String get catalogBodyparts => 'Parties du corps';

  @override
  String get catalogMuscles => 'Muscles';

  @override
  String get catalogNoBodypartHistory => 'Aucun historique de parties du corps.';

  @override
  String get catalogNoMuscleHistory => 'Aucun historique musculaire.';

  @override
  String get catalogExerciseTutorialTitle => 'Catalogue d’exercices';

  @override
  String get catalogExerciseTutorialBody => 'Vos exercices les plus utilisés apparaissent ici en premier. Touchez la carte pour ouvrir le catalogue complet, rechercher des mouvements et consulter les détails des exercices.';

  @override
  String get catalogAnatomyTutorialTitle => 'Anatomie ciblée';

  @override
  String get catalogAnatomyTutorialBody => 'Ce résumé présente les parties du corps et les muscles que vous entraînez le plus. Touchez un côté pour ouvrir la bibliothèque anatomique et voir des listes d’exercices ciblées.';

  @override
  String catalogTimesUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '1 fois',
    );
    return '$_temp0';
  }

  @override
  String catalogSetUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séries',
      one: '1 série',
    );
    return '$_temp0';
  }

  @override
  String get navEditorMinimumTabsError => 'Conservez au moins deux onglets actifs.';

  @override
  String get navEditorSavedMessage => 'Onglets de navigation enregistrés';

  @override
  String get navEditorTitle => 'Modifier les onglets de navigation';

  @override
  String get navEditorSubtitle => 'Choisissez ce qui apparaît dans la barre inférieure et réorganisez les onglets actifs.';

  @override
  String get navEditorSave => 'Enregistrer les onglets';

  @override
  String get navEditorActiveTitle => 'Onglets actifs';

  @override
  String get navEditorActiveSubtitle => 'Faites glisser les onglets pour les réorganiser. Le profil demeure accessible.';

  @override
  String get navEditorInactiveTitle => 'Onglets inactifs';

  @override
  String get navEditorInactiveSubtitle => 'Réactivez ces onglets lorsque vous souhaitez les retrouver.';

  @override
  String get navEditorNoInactiveTabs => 'Aucun onglet inactif.';

  @override
  String get navEditorAlwaysShown => 'Toujours affiché';

  @override
  String get navEditorVisible => 'Visible dans la navigation inférieure';

  @override
  String get navEditorHidden => 'Masqué de la navigation inférieure';

  @override
  String get trainTutorialSpacesTitle => 'Deux espaces d’entraînement';

  @override
  String get trainTutorialSpacesBody => 'L’aperçu garde les commandes d’entraînement prêtes à utiliser au premier plan. La section Plans permet de parcourir, générer et gérer vos plans enregistrés.';

  @override
  String get trainTutorialWeeklyTitle => 'Aperçu hebdomadaire';

  @override
  String get trainTutorialWeeklyBody => 'Voyez les parties du corps entraînées récemment. Touchez la liste des séries ciblées pour ouvrir le bilan hebdomadaire complet.';

  @override
  String get trainTutorialActivePlansTitle => 'Plans actifs';

  @override
  String get trainTutorialActivePlansBody => 'Les plans actifs sont les routines que vous souhaitez garder à portée de main. Utilisez le crayon pour choisir les plans affichés dans l’aperçu.';

  @override
  String get trainTutorialStartTitle => 'Commencer ou optimiser';

  @override
  String get trainTutorialStartBody => 'Commencer l’entraînement lance une séance vide. Optimiser crée une séance selon votre historique, l’équipement du profil, vos priorités et vos règles de récupération.';

  @override
  String get trainTutorialProfilesTitle => 'Profils de gym';

  @override
  String get trainTutorialProfilesBody => 'Changez de profil lorsque vous vous entraînez ailleurs afin que les séances générées et les substitutions utilisent seulement l’équipement disponible.';

  @override
  String get trainSelectProfileFirst => 'Veuillez d\'abord choisir un profil d\'entrainement.';

  @override
  String trainGeneratedPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans ont été générés.',
      one: '1 plan a été généré.',
    );
    return '$_temp0';
  }

  @override
  String trainNewPlanName(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Nouveau plan $number',
      one: 'Nouveau plan',
    );
    return '$_temp0';
  }

  @override
  String trainOptimizedWorkoutName(String date, String time) {
    return 'Entraînement optimisé $date $time';
  }

  @override
  String get trainRestTitle => 'Prenez le temps de recuperer';

  @override
  String get trainRestBody => 'Votre entrainement recent atteint deja plusieurs limites de parties du corps; un entrainement optimise pourrait trop reduire la recuperation.';

  @override
  String get commonOkay => 'OK';

  @override
  String get trainNoEligibleExercises => 'Aucun exercice compatible n\'a ete trouve pour ce profil.';

  @override
  String get trainAnotherWorkoutActive => 'Un autre entraînement est déjà en cours; il a été conservé sans modification.';

  @override
  String trainOptimizedStartFailed(String error) {
    return 'Impossible de demarrer l\'entrainement optimise : $error';
  }

  @override
  String trainOptimizedManualWeights(int count) {
    return 'Entrainement optimise demarre. $count exercice(s) ont encore besoin de poids saisis manuellement.';
  }

  @override
  String trainOptimizedStarterWeights(int count) {
    return 'Entrainement optimise demarre avec des poids de depart pour $count nouvel(aux) exercice(s).';
  }

  @override
  String get trainGymProfilesTooltip => 'Profils de gym';

  @override
  String get trainOverviewTab => 'Aperçu';

  @override
  String get trainPlansTab => 'Plans';

  @override
  String get trainActivePlans => 'Plans actifs';

  @override
  String get trainEditActivePlans => 'Modifier les plans actifs';

  @override
  String get trainSelectProfileForPlans => 'Sélectionnez un profil de gym pour choisir les plans actifs.';

  @override
  String get trainChooseActivePlans => 'Touchez le crayon pour choisir les plans affichés ici.';

  @override
  String get trainSelectedPlansMissing => 'Les plans sélectionnés ne sont plus disponibles. Touchez le crayon pour les mettre à jour.';

  @override
  String get trainArchivedPlans => 'Plans archivés';

  @override
  String get trainNoActivePlans => 'Aucun plan actif. Utilisez le crayon de la carte Plans actifs dans l’aperçu pour choisir les plans à garder à portée de main.';

  @override
  String get trainNoArchivedPlans => 'Aucun plan archivé.';

  @override
  String get trainManagePlans => 'Gérer les plans';

  @override
  String get trainPremadePlans => 'Plans préconçus';

  @override
  String trainPremadeDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routines sélectionnées peuvent être copiées dans vos plans.',
      one: 'Une routine sélectionnée peut être copiée dans vos plans.',
    );
    return '$_temp0';
  }

  @override
  String get trainBrowsePremadePlans => 'Parcourir les plans préconçus';

  @override
  String get trainGenerateCustomPlans => 'Générer des plans personnalisés';

  @override
  String get trainManuallyAddPlan => 'Ajouter un plan manuellement';

  @override
  String get trainStartWorkout => 'Commencer l’entraînement';

  @override
  String get trainOptimize => 'Optimiser';

  @override
  String get trainOptimizedSettings => 'Réglages de l’entraînement optimisé';

  @override
  String planManagementDefaultName(int id) {
    return 'Plan $id';
  }

  @override
  String get planManagementActiveTutorialTitle => 'Plans actifs';

  @override
  String get planManagementActiveTutorialBody => 'Ces plans restent visibles dans l’aperçu Entraînement. Utilisez Archiver pour masquer un plan sans le supprimer.';

  @override
  String get planManagementArchivedTutorialTitle => 'Plans archivés';

  @override
  String get planManagementArchivedTutorialBody => 'Les plans archivés restent enregistrés. Réactivez un plan ici pour le retrouver dans l’aperçu.';

  @override
  String planManagementUpdateFailed(String plan, String error) {
    return 'Impossible de mettre à jour $plan : $error';
  }

  @override
  String get planManagementTitle => 'Gérer les plans';

  @override
  String get planManagementLoadFailed => 'Impossible de charger les plans';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get planManagementIntro => 'Choisissez les plans à garder à portée de main dans l’aperçu Entraînement. Les plans archivés restent enregistrés et peuvent être réactivés en tout temps.';

  @override
  String get planManagementActiveSubtitle => 'Affichés dans l’aperçu Entraînement.';

  @override
  String get planManagementNoActive => 'Aucun plan actif. Activez un plan ci-dessous pour l’épingler dans l’aperçu.';

  @override
  String get planManagementArchive => 'Archiver';

  @override
  String get planManagementArchivedSubtitle => 'Plans enregistrés qui restent hors de l’aperçu.';

  @override
  String get planManagementNoArchived => 'Aucun plan archivé.';

  @override
  String get planManagementActivate => 'Activer';

  @override
  String get planManagementAutomatic => 'Plan automatique';

  @override
  String get planManagementVisible => 'Visible dans l’aperçu';

  @override
  String get planManagementHidden => 'Masqué de l’aperçu';

  @override
  String get presetsNoPlans => 'Aucun plan trouvé.';

  @override
  String get presetsNoProfile => 'Aucun profil sélectionné.';

  @override
  String get presetsLoadError => 'Erreur lors du chargement des plans';

  @override
  String presetsShowMore(int count) {
    return 'Afficher $count de plus';
  }

  @override
  String presetsShowMoreRemaining(int count, int remaining) {
    return 'Afficher $count de plus ($remaining restants)';
  }

  @override
  String planDefaultName(int number) {
    return 'Plan $number';
  }

  @override
  String get planArchive => 'Archiver';

  @override
  String get planActivate => 'Activer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonRename => 'Renommer';

  @override
  String get planActivated => 'Plan activé.';

  @override
  String get planArchived => 'Plan archivé.';

  @override
  String get planDeleteTitle => 'Supprimer le plan';

  @override
  String get planDeleteConfirmation => 'Voulez-vous vraiment supprimer ce plan?';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get planRenameTitle => 'Renommer le plan';

  @override
  String get planNameLabel => 'Nom du plan';

  @override
  String get optimizedTutorialBudgetTitle => 'Durée et volume de la séance';

  @override
  String get optimizedTutorialBudgetBody => 'Définissez la durée de l’entraînement optimisé et le nombre de séries pouvant être attribué à chaque exercice.';

  @override
  String get optimizedTutorialRepsTitle => 'Répétitions et poids';

  @override
  String get optimizedTutorialRepsBody => 'Ces choix déterminent la structure des séries, la cible de répétitions et la prudence des poids générés.';

  @override
  String get optimizedTutorialFocusTitle => 'Priorités par partie du corps';

  @override
  String get optimizedTutorialFocusBody => 'Privilégiez ou évitez des parties du corps pour le prochain entraînement optimisé sans modifier vos classements enregistrés.';

  @override
  String get commonReset => 'Réinitialiser';

  @override
  String get optimizedTutorialResetBody => 'La réinitialisation restaure les valeurs par défaut de Tonos si la configuration actuelle ne vous convient plus.';

  @override
  String get optimizedTutorialActionsTitle => 'Enregistrer ou commencer';

  @override
  String get optimizedTutorialActionsBody => 'Commencer maintenant utilise les valeurs affichées une seule fois. Enregistrer les conserve pour les prochains entraînements optimisés.';

  @override
  String optimizedValidationError(int maxSets) {
    return 'Entrez une durée, une cible de répétitions et une plage de séries valides entre 1 et $maxSets.';
  }

  @override
  String get optimizedBudgetDescription => 'Le calcul prévoit 3 minutes par série et 5 minutes pour commencer chaque exercice.';

  @override
  String get optimizedWorkoutDuration => 'Durée de l’entraînement';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get optimizedMinimumSets => 'Séries minimales par exercice';

  @override
  String get optimizedMaximumSets => 'Séries maximales par exercice';

  @override
  String get unitSets => 'séries';

  @override
  String get optimizedRepsWeightsTitle => 'Répétitions et poids';

  @override
  String get optimizedRepsWeightsDescription => 'Utilise les estimations de force tirées de l’historique lorsqu’elles sont disponibles. Facile et Moyen sont plus prudents que Difficile. Les nouveaux exercices utilisent des estimations de départ conservatrices.';

  @override
  String get optimizedRepPattern => 'Structure des répétitions';

  @override
  String get repModeMixed => 'Mixte';

  @override
  String get repModePyramid => 'Pyramidal';

  @override
  String get repModeConsistent => 'Constant';

  @override
  String get optimizedTargetReps => 'Répétitions cibles';

  @override
  String get unitReps => 'rép.';

  @override
  String get optimizedWeightIntensity => 'Intensité du poids';

  @override
  String get intensityEasy => 'Facile';

  @override
  String get intensityMedium => 'Moyen';

  @override
  String get intensityHard => 'Difficile';

  @override
  String get optimizedBodypartFocusTitle => 'Priorités par partie du corps';

  @override
  String get optimizedBodypartFocusDescription => 'Ces choix s’appliquent seulement au prochain entraînement optimisé. Touchez une fois pour privilégier, deux fois pour éviter, puis de nouveau pour effacer.';

  @override
  String get optimizedBodypartsUnavailable => 'Impossible de charger les parties du corps.';

  @override
  String get commonStartNow => 'Commencer maintenant';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get generateTutorialIntroTitle => 'Créer des plans';

  @override
  String get generateTutorialIntroBody => 'Cette page peut créer un plan ou un ensemble hebdomadaire équilibré selon votre profil de gym et vos préférences d’entraînement.';

  @override
  String get generateWorkoutSetupTitle => 'Configuration de l’entraînement';

  @override
  String get generateTutorialSetupBody => 'Définissez la durée des séances, le nombre de plans à créer et le nombre maximal de séries par exercice.';

  @override
  String get generateTrainingFocusTitle => 'Priorités d’entraînement';

  @override
  String get generateTutorialFocusBody => 'Privilégiez ou évitez des parties du corps. L’historique de 7 jours influence la génération seulement lorsque vous l’activez.';

  @override
  String get generateRepsWeightsTitle => 'Répétitions et poids';

  @override
  String get generateTutorialRepsBody => 'Choisissez une structure pyramidale, mixte ou constante, les répétitions cibles et l’intensité des poids de départ.';

  @override
  String get generateSetAllocationTitle => 'Répartition des séries';

  @override
  String get generateTutorialAllocationBody => 'Choisissez si les séries sont réparties uniformément ou selon vos classements de parties du corps ou de muscles.';

  @override
  String get generateTutorialGenerateTitle => 'Générer';

  @override
  String get generateTutorialGenerateBody => 'Lorsque tout vous convient, générez le plan ou l’ensemble de plans. Vous pourrez ensuite les examiner et les modifier.';

  @override
  String get generateValidationError => 'Entrez une durée, un nombre de plans, une limite de séries et une cible de répétitions valides.';

  @override
  String get generateNoViablePlans => 'Aucun plan viable n’a pu être généré avec les réglages actuels.';

  @override
  String generateFailed(String error) {
    return 'Impossible de générer les plans : $error';
  }

  @override
  String generateDiscardFailed(String error) {
    return 'Impossible de supprimer les plans générés : $error';
  }

  @override
  String get generateIntroTitle => 'Créez votre semaine de plans';

  @override
  String get generateIntroBody => 'Créez un plan ou un ensemble équilibré selon votre profil, vos priorités et vos limites.';

  @override
  String generatePlanCountPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans',
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
    return '$sets séries max.';
  }

  @override
  String generateSetupSummary(String plans, String minutes, String sets) {
    return '$plans plan(s), $minutes min, $sets séries max.';
  }

  @override
  String get generateSessionLength => 'Durée de la séance';

  @override
  String get generateSessionLengthHelp => 'Estimation : 3 min/série + 5 min/exercice.';

  @override
  String get generatePlansToCreate => 'Plans à créer';

  @override
  String generatePlansToCreateHelp(int maxPlans) {
    return 'Correspond habituellement aux jours d’entraînement par semaine. Maximum : $maxPlans.';
  }

  @override
  String get unitPlans => 'plans';

  @override
  String get generateMaxSetsPerExercise => 'Séries maximales par exercice';

  @override
  String generateSetLimitHelp(int minSets, int maxSets) {
    return 'De $minSets à $maxSets séries permises.';
  }

  @override
  String generateFocusSummary(int preferred, int avoided, String history) {
    return '$preferred privilégiées, $avoided évitées, historique de 7 jours $history';
  }

  @override
  String get generateHistoryUsing => 'utilisé';

  @override
  String get generateHistoryNotUsing => 'non utilisé';

  @override
  String get generateUseRecentTraining => 'Utiliser l’entraînement récent';

  @override
  String get generateUseRecentTrainingBody => 'Favorise les zones moins entraînées au cours des 7 derniers jours.';

  @override
  String get generateBodypartFocusInstruction => 'Touchez une fois pour privilégier, deux fois pour éviter, puis une troisième fois pour effacer.';

  @override
  String generateRepsSummary(String mode, String reps, String intensity) {
    return '$mode, $reps rép., intensité $intensity';
  }

  @override
  String get generateMixedBody => 'Pyramidal pour 3 séries ou plus; constant pour les exercices plus courts.';

  @override
  String get generatePyramidBody => 'La série maximale utilise le poids de travail généré.';

  @override
  String get generateConsistentBody => 'Mêmes répétitions et poids suggéré pour chaque série.';

  @override
  String get generateTargetRepsHelp => 'Répétitions maximales en mode pyramidal; constantes autrement.';

  @override
  String get generateEasyBody => 'Recommandation la plus prudente selon l’historique ou les données de départ.';

  @override
  String get generateMediumBody => 'Recommandation équilibrée de poids de travail.';

  @override
  String get generateHardBody => 'Recommandation la plus lourde, toujours arrondie et adaptée à l’effort.';

  @override
  String get generateRequirementBodyparts => 'Classement des parties du corps';

  @override
  String get generateRequirementMuscles => 'Classement des muscles';

  @override
  String get generateRequirementEven => 'Répartition uniforme';

  @override
  String get generateEvenCoverageTitle => 'Couverture uniforme des parties du corps';

  @override
  String get generateEvenCoverageBody => 'Répartit largement le travail entre les parties du corps disponibles.';

  @override
  String get generateBodypartRankingsTitle => 'Utiliser le classement des parties du corps';

  @override
  String get generateBodypartRankingsBody => 'Accorde plus de travail planifié aux parties du corps mieux classées.';

  @override
  String get generateRankBodyparts => 'Classer les parties du corps';

  @override
  String get generateMuscleRankingsTitle => 'Utiliser le classement des muscles';

  @override
  String get generateMuscleRankingsBody => 'Répartit le travail selon vos priorités musculaires classées.';

  @override
  String get generateRankMuscles => 'Classer les muscles';

  @override
  String get generateGenerating => 'Génération...';

  @override
  String generateButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Générer $count plans',
      one: 'Générer le plan',
    );
    return '$_temp0';
  }

  @override
  String generatePartialMessage(int generated, int requested) {
    return '$generated plans sur $requested ont été générés. Les réglages actuels ont limité les autres.';
  }

  @override
  String generateSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans ont été générés. Examinez-les lorsque vous êtes prêt.',
      one: 'Le plan généré a été ajouté. Examinez-le lorsque vous êtes prêt.',
    );
    return '$_temp0';
  }

  @override
  String generateMoreNames(int count) {
    return '$count de plus';
  }

  @override
  String get generateStarterEstimatedBody => 'Des poids de départ ont été estimés pour les nouveaux exercices. Ajustez-les au besoin après votre première série.';

  @override
  String get generateStarterUnavailableBody => 'Certains exercices nécessitent encore des poids manuels, car aucune estimation de départ sûre n’est disponible.';

  @override
  String get generateStarterDialogTitle => 'Poids de départ ajoutés';

  @override
  String get generatePageTitle => 'Générer des plans';

  @override
  String get generateDiscarding => 'Suppression...';

  @override
  String get generateReviewPlans => 'Examiner les plans';

  @override
  String get sessionTutorialCardsTitle => 'Cartes d’exercices';

  @override
  String get sessionTutorialCardsBody => 'Chaque carte contient un exercice. Ouvrez-la pour modifier les poids et les répétitions, puis cochez les séries à mesure que vous les terminez.';

  @override
  String get sessionTutorialAddTitle => 'Ajouter des exercices';

  @override
  String get sessionTutorialAddBody => 'Utilisez ce bouton pour ajouter un exercice du catalogue pendant l’entraînement.';

  @override
  String get sessionTutorialFinishTitle => 'Terminer l’entraînement';

  @override
  String get sessionTutorialFinishBody => 'Lorsque vous avez terminé, enregistrez la séance afin que Tonos mette à jour votre historique, vos analyses et vos widgets de progression.';

  @override
  String get sessionTimerTitle => 'Chronomètre d’entraînement';

  @override
  String get sessionTitle => 'Séance d’entraînement';

  @override
  String get sessionNoExercises => 'Aucun exercice ajouté.';

  @override
  String get sessionNeedCompletedSet => 'Terminez au moins une série avant de terminer l’entraînement.';

  @override
  String sessionSaveFailed(String error) {
    return 'Impossible d’enregistrer l’entraînement. Votre entraînement en cours reste disponible. $error';
  }

  @override
  String get sessionFinishWorkout => 'Terminer l’entraînement';

  @override
  String get sessionResume => 'Reprendre';

  @override
  String get sessionExit => 'Quitter';

  @override
  String get sessionCompletedSaved => 'Le travail terminé a été enregistré dans le journal.';

  @override
  String get sessionCancelled => 'Entraînement annulé.';

  @override
  String sessionEndFailed(String error) {
    return 'Impossible de terminer l’entraînement : $error';
  }

  @override
  String get sessionCancelQuestion => 'Annuler l’entraînement?';

  @override
  String get sessionCancelBody => 'Cette action supprime l’entraînement en cours sans l’ajouter à votre historique.';

  @override
  String get sessionKeepWorkout => 'Garder l’entraînement';

  @override
  String get sessionCancelWorkout => 'Annuler l’entraînement';

  @override
  String get sessionEndQuestion => 'Terminer l’entraînement?';

  @override
  String get sessionCancelDelete => 'Annuler et supprimer';

  @override
  String get sessionEndSave => 'Terminer et enregistrer';

  @override
  String get sessionRememberChoice => 'Mémoriser ce choix';

  @override
  String get sessionRememberChoiceBody => 'Vous pourrez le modifier plus tard dans les réglages de gym et d’entraînement.';

  @override
  String get sessionCompleteLoadError => 'Erreur lors du chargement de la séance';

  @override
  String get sessionCompleteTitle => 'ENTRAÎNEMENT TERMINÉ';

  @override
  String get sessionMetricExercises => 'Exercices';

  @override
  String get sessionMetricSets => 'Séries';

  @override
  String get sessionMetricDuration => 'Durée';

  @override
  String get sessionMetricVolume => 'Volume';

  @override
  String get commonDone => 'Terminé';

  @override
  String get recordMonthly => 'Mensuel';

  @override
  String get recordAllTime => 'Tout temps';

  @override
  String get recordFirst => 'Premier résultat';

  @override
  String recordRepBest(int reps) {
    return 'Meilleur à $reps rép.';
  }

  @override
  String get recordVolumeBest => 'Meilleur volume';

  @override
  String sessionEstimatedMax(String weight) {
    return '1RM est.=$weight';
  }

  @override
  String durationMinutesCompact(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHoursCompact(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutesCompact(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get planUnsavedChangesTitle => 'Modifications non enregistrées';

  @override
  String get planDiscardChangesQuestion => 'Abandonner les modifications?';

  @override
  String get planDiscard => 'Abandonner';

  @override
  String get planTutorialEditTitle => 'Modifier le plan';

  @override
  String get planTutorialEditBody => 'Utilisez cette option pour renommer le plan, réorganiser ou ajouter des exercices, remplacer des mouvements et modifier les séries.';

  @override
  String get planTutorialSummaryTitle => 'Résumé du plan';

  @override
  String get planTutorialSummaryBody => 'Affiche la durée et le volume estimés, ainsi que les principales parties du corps ciblées avant de commencer.';

  @override
  String get planTutorialExerciseCardsTitle => 'Cartes d’exercices';

  @override
  String get planTutorialExerciseCardsBody => 'Ouvrez les cartes pour consulter les séries prévues. En mode modification, utilisez le menu pour remplacer ou supprimer des exercices.';

  @override
  String get planTutorialStartOrSaveTitle => 'Commencer ou enregistrer';

  @override
  String get planTutorialStartOrSaveBody => 'Commencer la séance lance ce plan comme entraînement. En mode modification, le bouton enregistre vos changements.';

  @override
  String get planGuideNameTitle => 'Nommez votre plan';

  @override
  String get planGuideNameBody => 'Donnez à ce plan un nom que vous reconnaîtrez, comme Haut du corps ou Jour 1.';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get planGuideBrowseTitle => 'Parcourir les exercices';

  @override
  String get planGuideBrowseBody => 'Touchez le bouton + pour choisir le premier exercice de ce plan.';

  @override
  String get planGuideWeightTitle => 'Choisissez un poids';

  @override
  String get planGuideWeightBody => 'Entrez un poids de départ pour la première série. Utilisez 0 pour un exercice au poids du corps.';

  @override
  String get planGuideWeightSet => 'Poids choisi';

  @override
  String get planGuideRepsTitle => 'Choisissez vos répétitions';

  @override
  String get planGuideRepsBody => 'Entrez le nombre de répétitions prévu pour cette série.';

  @override
  String get planGuideRepsSet => 'Répétitions choisies';

  @override
  String get planGuideAddSetTitle => 'Ajoutez des séries';

  @override
  String get planGuideAddSetBody => 'Utilisez Ajouter une série lorsque vous en avez besoin d’une autre. Les nouvelles séries reprennent les valeurs de la série précédente.';

  @override
  String get planGuideSaveTitle => 'Enregistrez votre plan';

  @override
  String get planGuideSaveBody => 'Touchez Enregistrer le plan pour le conserver et revenir à l’aperçu de l’intégration.';

  @override
  String planSaveFailed(String error) {
    return 'Impossible d’enregistrer le plan. La version précédente est inchangée. $error';
  }

  @override
  String get planOngoingWorkoutKept => 'Votre entraînement en cours a été conservé. Terminez-le ou annulez-le avant de commencer ce plan.';

  @override
  String get planDeleteBody => 'Voulez-vous vraiment supprimer ce plan?';

  @override
  String get planDeletePreset => 'Supprimer le plan';

  @override
  String get planDisableAutomatic => 'Désactiver le mode automatique';

  @override
  String get planMakeAutomatic => 'Rendre automatique';

  @override
  String get planAutomaticSettings => 'Réglages automatiques';

  @override
  String get planProgression => 'Progression du plan';

  @override
  String get planNoExercises => 'Aucun exercice dans ce plan.';

  @override
  String get planSavePreset => 'Enregistrer le plan';

  @override
  String get planStartSession => 'Commencer la séance';

  @override
  String get commonName => 'Nom';

  @override
  String get commonBack => 'Retour';

  @override
  String get flowMethodWeight => 'Poids';

  @override
  String get flowMethodReps => 'Répétitions';

  @override
  String get flowMethodAddSet => 'Ajouter une série';

  @override
  String get flowMethodDeleteSet => 'Supprimer une série';

  @override
  String get flowAppDefaultTitle => 'Progression par défaut de l’application';

  @override
  String get flowProfileDefaultTitle => 'Progression par défaut du profil de gym';

  @override
  String get flowPlanSubtitle => 'Définissez comment ce plan progresse après chaque entraînement.';

  @override
  String get flowAppDefaultSubtitle => 'Définissez le flux de progression initial pour les nouveaux profils de gym.';

  @override
  String flowProfileDefaultSubtitle(String profileName) {
    return 'Définissez le flux de progression initial des nouveaux plans dans $profileName.';
  }

  @override
  String get flowThisGymProfile => 'ce profil de gym';

  @override
  String get flowManageMethods => 'Gérer les actions';

  @override
  String get flowAddNewMethod => 'Ajouter une action';

  @override
  String get flowNewMethod => 'Nouvelle action';

  @override
  String get flowFactor => 'Facteur';

  @override
  String get flowAmount => 'Valeur';

  @override
  String get flowExplicit => 'Explicite';

  @override
  String get flowCopyFromSet => 'Copier depuis une série';

  @override
  String get flowWeight => 'Poids';

  @override
  String get flowReps => 'Répétitions';

  @override
  String get flowSetIndex => 'Indice de série (-1 = dernière)';

  @override
  String get flowDeleteLastSetBody => 'Cette action supprimera la dernière série.';

  @override
  String get flowMethodNameRequired => 'Le nom de l’action ne peut pas être vide';

  @override
  String get flowManageActionsTooltip => 'Gérer les actions de progression';

  @override
  String get flowAddBranchTitle => 'Ajouter une branche';

  @override
  String get flowAddBranchSubtitle => 'Choisissez où le prochain succès ou échec doit mener.';

  @override
  String get flowBranchFrom => 'Bifurquer depuis';

  @override
  String get flowSuccess => 'Succès';

  @override
  String get flowMiss => 'Échec';

  @override
  String get flowAttachActionTitle => 'Associer une action de progression';

  @override
  String get flowAttachActionSubtitle => 'Appliquez un ajustement de chaque type à un nœud du flux.';

  @override
  String get flowApplyActionTo => 'Appliquer l’action à';

  @override
  String get flowProgressionAction => 'Action de progression';

  @override
  String get flowAddAction => '+ Action';

  @override
  String get flowRemoveAction => '- Action';

  @override
  String get flowRemoveNode => '- Noeud';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get rulesEditAppDefault => 'Modifier la règle par défaut de l’application';

  @override
  String get rulesEditProfileDefault => 'Modifier la règle par défaut du profil';

  @override
  String get rulesAddAppDefault => 'Ajouter une règle par défaut de l’application';

  @override
  String get rulesAddProfileDefault => 'Ajouter une règle par défaut du profil';

  @override
  String get rulesCopy => 'Copier';

  @override
  String get rulesCopyIndex => 'Indice à copier';

  @override
  String get rulesDeleteLastSetBody => 'Cette règle supprimera la dernière série.';

  @override
  String get rulesNameRequired => 'Le nom de la règle ne peut pas être vide';

  @override
  String get rulesProfilesLowercase => 'profils';

  @override
  String get rulesPlansLowercase => 'plans';

  @override
  String rulesAddToExistingTitle(String destination) {
    return 'Ajouter aux $destination existants?';
  }

  @override
  String rulesAddToExistingBody(String name, int count, String destination) {
    return 'Rendre \"$name\" disponible dans $count $destination existants? Les règles du même nom et les flux de progression enregistrés ne seront pas modifiés.';
  }

  @override
  String get rulesNotNow => 'Pas maintenant';

  @override
  String rulesAddTo(String destination) {
    return 'Ajouter aux $destination';
  }

  @override
  String rulesNoExistingNeeded(String destination) {
    return 'Aucun $destination existant n’avait besoin de cette règle.';
  }

  @override
  String rulesCopiedMessage(String name, int count, String destination) {
    return 'Ajout de \"$name\" à $count $destination.';
  }

  @override
  String get rulesPropagationFailed => 'Impossible d’ajouter la règle aux éléments existants.';

  @override
  String get rulesOptionsTooltip => 'Options de la règle';

  @override
  String get rulesPageTitle => 'Règles de progression des entraînements';

  @override
  String get rulesPageSubtitle => 'Créez des règles réutilisables pour modifier les poids, répétitions et séries après les tentatives d’entraînement.';

  @override
  String get rulesHowDefaultsTitle => 'Fonctionnement des valeurs par défaut';

  @override
  String get rulesHowDefaultsBody => 'Les valeurs par défaut de l’application sont copiées dans les nouveaux profils de gym. Celles du profil sont copiées dans les nouveaux plans, afin que les modifications ultérieures ne changent pas les plans existants.';

  @override
  String get rulesAppDefaultsTitle => 'Valeurs par défaut de l’application';

  @override
  String get rulesAppDefaultsSubtitle => 'Les règles initiales des nouveaux profils de gym.';

  @override
  String get rulesNoAppDefaults => 'Aucune règle générale n’a encore été créée.';

  @override
  String get rulesAddApp => 'Ajouter une règle générale';

  @override
  String get rulesGymProfilesTitle => 'Profils de gym';

  @override
  String get rulesGymProfilesSubtitle => 'Chaque profil conserve ensemble ses valeurs par défaut et les règles de ses plans.';

  @override
  String get rulesNoProfiles => 'Créez un profil de gym pour ajouter des règles de profil et de plan.';

  @override
  String rulesProfileSummary(int profileRules, int planRules) {
    return '$profileRules règles de profil • $planRules règles de plan';
  }

  @override
  String get rulesProfileDefaultsTitle => 'Valeurs par défaut du profil';

  @override
  String get rulesProfileDefaultsSubtitle => 'Les règles initiales des nouveaux plans de ce profil.';

  @override
  String get rulesNoProfileDefaults => 'Ce profil n’a aucune règle par défaut.';

  @override
  String get rulesAddProfile => 'Ajouter une règle de profil';

  @override
  String get rulesPlansTitle => 'Plans';

  @override
  String get rulesNoPlans => 'Aucun plan n’appartient encore à ce profil de gym.';

  @override
  String get rulesPlanOnlySubtitle => 'Règles utilisées uniquement par ce plan.';

  @override
  String get rulesNoPlanRules => 'Ce plan n’a aucune règle de progression propre.';

  @override
  String get rulesAddPlan => 'Ajouter une règle de plan';

  @override
  String get rulesAppDefaultsChip => 'Défauts de l’application';

  @override
  String get rulesProfilesChip => 'Profils';

  @override
  String get rulesPlansChip => 'Plans';

  @override
  String get rulesEditPlan => 'Modifier la règle';

  @override
  String get rulesAddPlanTitle => 'Ajouter une règle';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get flowPageTitle => 'Flux de progression des entraînements';

  @override
  String get flowPageSubtitle => 'Définissez les chemins qui déterminent comment les actions de progression sont appliquées après les résultats d’entraînement.';

  @override
  String get flowHowCopiedTitle => 'Copie des flux';

  @override
  String get flowHowCopiedBody => 'Les flux de l’application deviennent le point de départ des nouveaux profils de gym. Les flux du gym deviennent le point de départ des nouveaux plans. Les modifications ultérieures restent limitées au flux ouvert ici.';

  @override
  String get flowLoadError => 'Impossible de charger les flux de progression des entraînements.';

  @override
  String get flowAppDefaultsSubtitle => 'Le flux initial des nouveaux profils de gym.';

  @override
  String get flowAppDefaultEntry => 'Flux par défaut de l’application';

  @override
  String get flowGymProfilesSubtitle => 'Chaque profil possède ses valeurs par défaut et ses propres flux de plan.';

  @override
  String get flowNoProfiles => 'Créez un profil de gym pour définir des flux de profil et de plan.';

  @override
  String get flowNoSavedYet => 'Aucun flux enregistré';

  @override
  String flowSummary(int nodes, int branches, int actions) {
    return '$nodes nœuds | $branches branches | $actions actions';
  }

  @override
  String flowPlansAvailable(int count) {
    return '$count flux de plan disponibles';
  }

  @override
  String get flowGymDefaultEntry => 'Flux par défaut du gym';

  @override
  String get gymSettingsTitle => 'Réglages de gym et d’entraînement';

  @override
  String get gymSettingsSubtitle => 'Ajustez la génération d’entraînements, les analyses et le comportement des flux d’entraînement.';

  @override
  String get gymSettingsLogicTitle => 'Logique d’entraînement';

  @override
  String get gymSettingsLogicSubtitle => 'Réglages qui influencent les plans et les entraînements générés.';

  @override
  String get gymSettingsWorkoutTitle => 'Réglages d’entraînement';

  @override
  String get gymSettingsWorkoutSubtitle => 'Limites de volume, valeurs d’analyse par défaut et contrôles d’entraînement.';

  @override
  String get gymSettingsExitTitle => 'Quitter l’entraînement en cours';

  @override
  String get gymSettingsFlowToolsTitle => 'Outils de flux';

  @override
  String get gymSettingsFlowToolsSubtitle => 'Gérez les chemins et les actions de progression enregistrés.';

  @override
  String get gymSettingsFlowsSubtitle => 'Modifiez les flux de progression de l’application, des gyms et des plans.';

  @override
  String get gymSettingsRulesSubtitle => 'Gérez les règles de progression des poids, répétitions et séries.';

  @override
  String get gymExitAsk => 'Demander à chaque fois';

  @override
  String get gymExitDiscard => 'Annuler l’entraînement';

  @override
  String get gymExitSave => 'Terminer et enregistrer';

  @override
  String get gymExitAskBody => 'Demander avant de terminer le travail effectué.';

  @override
  String get gymExitDiscardBody => 'Annuler sans enregistrer le travail effectué.';

  @override
  String get gymExitSaveBody => 'Enregistrer le travail effectué dans le journal.';

  @override
  String get commonAll => 'Tous';

  @override
  String get catalogGuideChooseTitle => 'Choisissez un exercice';

  @override
  String get catalogGuideChooseBody => 'Touchez une ligne d’exercice pour la sélectionner. La recherche et les filtres peuvent vous aider à trouver le bon mouvement.';

  @override
  String get catalogGuideAddTitle => 'Ajoutez-le à votre plan';

  @override
  String catalogGuideAddBody(String exerciseName) {
    return 'Touchez + pour ajouter $exerciseName et revenir à votre plan.';
  }

  @override
  String get catalogGuideSearchTitle => 'Rechercher des exercices';

  @override
  String get catalogGuideSearchBody => 'Recherchez par nom lorsque vous savez déjà quel mouvement vous voulez.';

  @override
  String get catalogFilters => 'Filtres';

  @override
  String get catalogGuideFiltersBody => 'Filtrez par profil de gym, équipement, partie du corps ou muscle pour restreindre rapidement le catalogue.';

  @override
  String get catalogGuideRowsTitle => 'Lignes d’exercices';

  @override
  String get catalogGuideRowsBody => 'Chaque ligne affiche l’équipement et une carte corporelle. Touchez-la pour les détails ou sélectionnez la ligne pour choisir l’exercice.';

  @override
  String get catalogSelectedFilters => 'Filtres sélectionnés';

  @override
  String get catalogUseWorkspaceProfile => 'Utiliser le profil actif';

  @override
  String get catalogWorkspaceProfile => 'Profil actif';

  @override
  String get catalogEquipment => 'Équipement';

  @override
  String get catalogFocusArea => 'Zone ciblée';

  @override
  String get catalogSpecificMuscle => 'Muscle précis';

  @override
  String get catalogPageTitle => 'Catalogue d’exercices';

  @override
  String get catalogSearchExercises => 'Rechercher des exercices';

  @override
  String get catalogNoMatches => 'Aucun exercice ne correspond aux filtres.';

  @override
  String get catalogOpenExerciseInfo => 'Ouvrir les informations sur l’exercice';

  @override
  String get commonClose => 'Fermer';

  @override
  String get exerciseDetailOpenImage => 'Ouvrir l’image de l’exercice';

  @override
  String get exerciseDetailTutorialTitle => 'Détails de l’exercice';

  @override
  String get exerciseDetailTutorialBody => 'Le titre de la fiche correspond à l’exercice ouvert. Fermez-la ici lorsque vous avez terminé.';

  @override
  String get exerciseDetailTabsTutorialTitle => 'Détails, mesures, historique';

  @override
  String get exerciseDetailTabsTutorialBody => 'Utilisez ces onglets pour passer des instructions aux meilleures charges et aux séances récentes.';

  @override
  String get exerciseDetailContextTutorialTitle => 'Contexte de l’exercice';

  @override
  String get exerciseDetailContextTutorialBody => 'L’onglet Détails présente l’équipement, les parties du corps et les muscles travaillés, ainsi que les notes de forme.';

  @override
  String get exerciseDetailSessionOpenFailed => 'Impossible d’ouvrir la séance d’entraînement.';

  @override
  String get exerciseDetailSessionNotFound => 'La séance d’entraînement est introuvable.';

  @override
  String get exerciseDetailNoEquipment => 'Aucun équipement n’est indiqué pour cet exercice.';

  @override
  String get exerciseDetailTargetAnatomy => 'Anatomie ciblée';

  @override
  String get exerciseDetailBodyParts => 'Parties du corps';

  @override
  String get exerciseDetailNoBodyParts => 'Aucune partie du corps n’est indiquée.';

  @override
  String get exerciseDetailMuscles => 'Muscles';

  @override
  String get exerciseDetailNoMuscles => 'Aucun muscle n’est indiqué.';

  @override
  String get exerciseDetailSetup => 'Mise en place';

  @override
  String get exerciseDetailNoSetup => 'Aucune instruction de mise en place n’est fournie.';

  @override
  String get exerciseDetailExecution => 'Exécution';

  @override
  String get exerciseDetailNoExecution => 'Aucune note d’exécution n’est fournie.';

  @override
  String get exerciseDetailTips => 'Conseils';

  @override
  String get exerciseDetailNoTips => 'Aucun conseil supplémentaire.';

  @override
  String get exerciseDetailFormGuide => 'Guide de forme';

  @override
  String get exerciseDetailOpenHeatmap => 'Ouvrir la carte corporelle ciblée';

  @override
  String get exerciseDetailNoHeatmap => 'Aucune zone corporelle ciblée n’est disponible';

  @override
  String get exerciseDetailZoomHint => 'Pincez ou faites glisser pour zoomer';

  @override
  String get exerciseDetailLoadingBestLifts => 'Chargement des meilleures performances';

  @override
  String get exerciseDetailLoadingBestLiftsBody => 'Vos records de séries terminées sont en cours de calcul.';

  @override
  String get exerciseDetailMetricsUnavailable => 'Mesures indisponibles';

  @override
  String get exerciseDetailMetricsUnavailableBody => 'Rouvrez cet exercice pour charger les records de séries terminées.';

  @override
  String get exerciseDetailNoBestLifts => 'Aucune meilleure performance';

  @override
  String get exerciseDetailNoBestLiftsBody => 'Terminez une série avec charge pour commencer à suivre les meilleurs résultats par répétition.';

  @override
  String get exerciseDetailWeek => 'Semaine';

  @override
  String get exerciseDetailMonth => 'Mois';

  @override
  String get exerciseDetailAllTime => 'Tout temps';

  @override
  String exerciseDetailTimeframeMetrics(String timeframe) {
    return 'Mesures : $timeframe';
  }

  @override
  String get exerciseDetailTopEstimatedOneRm => 'Meilleur 1RM est.';

  @override
  String get exerciseDetailVolumeBest => 'Meilleur volume';

  @override
  String get exerciseDetailRepBests => 'Meilleurs résultats par répétition';

  @override
  String get exerciseDetailRepBestsBody => 'Meilleure charge terminée pour chaque nombre de répétitions';

  @override
  String exerciseDetailRanges(int count) {
    return '$count plages';
  }

  @override
  String get exerciseDetailHistoryLoadFailed => 'Impossible de charger l’historique de l’exercice.';

  @override
  String get exerciseDetailNoHistory => 'Aucun historique pour cet exercice.';

  @override
  String get exerciseDetailPerformanceTrend => 'Tendance de performance';

  @override
  String get exerciseDetailBestWeight => 'Meilleur poids';

  @override
  String get exerciseDetailEstimatedOneRm => '1RM estimé';

  @override
  String get exerciseDetailLoadingSessions => 'Chargement des séances';

  @override
  String get exerciseDetailLoadMoreSessions => 'Charger 10 séances de plus';

  @override
  String get exerciseDetailResizeLabel => 'Redimensionner les détails de l’exercice';

  @override
  String get exerciseDetailResizeHint => 'Faites glisser vers le haut ou le bas pour redimensionner la fiche';

  @override
  String get exerciseDetailTabDetails => 'Détails';

  @override
  String get exerciseDetailTabMetrics => 'Mesures';

  @override
  String get exerciseDetailTabRecords => 'Historique';

  @override
  String exerciseDetailOpenWorkoutWithSets(int count) {
    return 'Ouvrir l’entraînement avec $count séries terminées';
  }

  @override
  String exerciseDetailSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séries',
      one: '1 série',
    );
    return '$_temp0';
  }

  @override
  String exerciseDetailEstimatedMax(String weight) {
    return '1RM est. $weight';
  }

  @override
  String get exerciseDetailReps => 'rép.';

  @override
  String get exerciseDetailSetVolume => 'Volume de la série';

  @override
  String get exerciseDetailNoChartData => 'Aucun record de série terminée à afficher pour le moment.';

  @override
  String get exerciseDetailWeightAbbreviation => 'Pds';

  @override
  String get exerciseDetailEstimatedAbbreviation => 'Est.';

  @override
  String get exerciseDetailTopAbbreviation => 'Meilleur';

  @override
  String exerciseDetailSectionLabel(String title) {
    return 'Section $title';
  }

  @override
  String get logbookTutorialCalendarTitle => 'Calendrier du journal';

  @override
  String get logbookTutorialCalendarBody => 'Utilisez M, 3M, A et 4A pour parcourir votre historique d\'entraînements. Sélectionnez un jour, une semaine, un mois ou une année pour voir les séances et les statistiques de cette période.';

  @override
  String get fullHistoryTitle => 'Toutes les séances';

  @override
  String get fullHistoryLoadError => 'Impossible de charger les séances enregistrées.';

  @override
  String get fullHistoryEmpty => 'Aucune séance enregistrée.';

  @override
  String fullHistorySessionSummary(String date, int minutes) {
    return '$date - $minutes min';
  }

  @override
  String get weeklySetsTitle => 'Aperçu hebdomadaire des séries';

  @override
  String get weeklySetsLoadError => 'Impossible de charger votre aperçu hebdomadaire d\'entraînement.';

  @override
  String get weeklySetsBodyParts => 'Parties du corps';

  @override
  String get weeklySetsMuscles => 'Muscles';

  @override
  String get weeklySetsTotal => 'Séries totales';

  @override
  String get weeklySetsTime => 'Durée';

  @override
  String get weeklySetsVolume => 'Volume';

  @override
  String get weeklySetsNoBodyParts => 'Aucune série de parties du corps pour le moment.';

  @override
  String get weeklySetsNoMuscles => 'Aucune série de muscles pour le moment.';

  @override
  String weeklySetsCount(String count) {
    return '$count séries';
  }

  @override
  String get weeklySetsTutorialOverviewTitle => 'Aperçu hebdomadaire';

  @override
  String get weeklySetsTutorialOverviewBody => 'Résume les sept derniers jours avec une carte corporelle, le total de séries, la durée et le volume.';

  @override
  String get weeklySetsTutorialAnatomyTitle => 'Parties du corps ou muscles';

  @override
  String get weeklySetsTutorialAnatomyBody => 'Passez des unités de séries par partie du corps aux unités par muscle.';

  @override
  String get weeklySetsTutorialStatusTitle => 'État des séries';

  @override
  String get weeklySetsTutorialStatusBody => 'Chaque ligne est teintée selon que votre travail récent est sous, dans ou au-dessus de sa plage recommandée. Touchez une ligne pour voir les exercices associés.';

  @override
  String get workoutDetailTutorialSummaryTitle => 'Résumé de l\'entraînement';

  @override
  String get workoutDetailTutorialSummaryBody => 'Consultez le total de séries, le volume, la durée, le nombre d\'exercices et les parties du corps travaillées.';

  @override
  String get workoutDetailTutorialExercisesTitle => 'Historique des exercices';

  @override
  String get workoutDetailTutorialExercisesBody => 'Chaque exercice affiche les séries terminées durant cette séance. Touchez les détails pour l\'inspecter.';

  @override
  String get workoutDetailTutorialEditTitle => 'Modifier la séance';

  @override
  String get workoutDetailTutorialEditBody => 'Utilisez le mode de modification pour corriger les séries, les répétitions ou les exercices après l\'entraînement.';

  @override
  String get workoutDetailTutorialReuseTitle => 'Réutiliser cet entraînement';

  @override
  String get workoutDetailTutorialReuseBody => 'Refaites l\'entraînement ou enregistrez la séance terminée comme plan réutilisable.';

  @override
  String get workoutDetailDeleteTitle => 'Supprimer la séance';

  @override
  String get workoutDetailDeleteBody => 'Voulez-vous vraiment supprimer cette séance?';

  @override
  String get workoutDetailDeleteFailed => 'Impossible de supprimer cette séance.';

  @override
  String get workoutDetailChangesSaved => 'Modifications enregistrées.';

  @override
  String get workoutDetailSaveFailed => 'Impossible d\'enregistrer les modifications. La séance précédente reste inchangée.';

  @override
  String get workoutDetailFinishCurrentFirst => 'Terminez votre entraînement en cours avant de refaire celui-ci.';

  @override
  String get workoutDetailOngoingWorkoutKept => 'Votre entraînement en cours a été conservé. Terminez-le ou annulez-le avant de refaire cet entraînement.';

  @override
  String get workoutDetailRepeatFailed => 'Impossible de refaire cet entraînement.';

  @override
  String get workoutDetailSaveAsPlan => 'Enregistrer comme plan';

  @override
  String get workoutDetailPlanName => 'Nom du plan';

  @override
  String workoutDetailPlanSaved(String name) {
    return '« $name » a été enregistré comme plan.';
  }

  @override
  String get workoutDetailPlanSaveFailed => 'Impossible d\'enregistrer le plan.';

  @override
  String workoutDetailDefaultPlanName(String date) {
    return 'Entraînement $date';
  }

  @override
  String get workoutDetailUnsavedTitle => 'Modifications non enregistrées';

  @override
  String get workoutDetailUnsavedBody => 'Vous avez des modifications non enregistrées. Voulez-vous les abandonner et quitter?';

  @override
  String get workoutDetailDiscard => 'Abandonner';

  @override
  String get workoutDetailTitle => 'Détails de l\'entraînement';

  @override
  String get workoutDetailStopEditing => 'Arrêter la modification';

  @override
  String get workoutDetailEditSession => 'Modifier la séance';

  @override
  String get workoutDetailDeleteSession => 'Supprimer la séance';

  @override
  String get workoutDetailLoadFailed => 'Impossible de charger cette séance.';

  @override
  String get workoutDetailEmpty => 'Aucun exercice dans cette séance.';

  @override
  String get workoutDetailSaveChanges => 'Enregistrer les modifications';

  @override
  String get workoutDetailRepeat => 'Refaire l\'entraînement';

  @override
  String get workoutDetailPastWorkout => 'Entraînement passé';

  @override
  String workoutDetailCompletedSets(int count) {
    return '$count séries terminées';
  }

  @override
  String get workoutDetailVolume => 'Volume';

  @override
  String get workoutDetailDuration => 'Durée';

  @override
  String get workoutDetailExercises => 'Exercices';

  @override
  String get workoutDetailExerciseInfo => 'Informations sur l\'exercice';

  @override
  String get workoutDetailBest => 'Meilleur';

  @override
  String workoutDetailEstimatedOneRm(String weight) {
    return '1RM = $weight';
  }

  @override
  String get logbookCalendarLoadFailed => 'Impossible de charger le calendrier des entraînements.';

  @override
  String get logbookNoWorkouts => 'Aucun entraînement consigné';

  @override
  String logbookWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entraînements',
      one: '1 entraînement',
    );
    return '$_temp0';
  }

  @override
  String get logbookPreviousMonth => 'Mois précédent';

  @override
  String get logbookNextMonth => 'Mois suivant';

  @override
  String get logbookPreviousThreeMonths => '3 mois précédents';

  @override
  String get logbookNextThreeMonths => '3 mois suivants';

  @override
  String get logbookPreviousYear => 'Année précédente';

  @override
  String get logbookNextYear => 'Année suivante';

  @override
  String logbookWeekShort(int week) {
    return 'S$week';
  }

  @override
  String logbookMonthWeek(String month, int week) {
    return '$month, semaine $week';
  }

  @override
  String get logbookWorkouts => 'Entraînements';

  @override
  String get logbookTotalTime => 'Durée totale';

  @override
  String get logbookTotalVolume => 'Volume total';

  @override
  String get logbookViewAllSessions => 'Voir toutes les séances';

  @override
  String logbookSessionSummary(int minutes, int exercises, int sets, String volume) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises exercices',
      one: '1 exercice',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets séries',
      one: '1 série',
    );
    return '$minutes min - $_temp0 - $_temp1 - $volume';
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
  String get dashboardHideSection => 'Masquer la section';

  @override
  String get dashboardAllSectionsShown => 'Toutes les sections sont affichées';

  @override
  String dashboardHiddenSectionCount(int count) {
    return '$count section(s) masquée(s)';
  }

  @override
  String get dashboardShowHiddenSections => 'Afficher les sections masquées';

  @override
  String get dashboardReset => 'Réinitialiser le tableau de bord';

  @override
  String get dashboardEmptyTitle => 'Votre tableau de bord est vide';

  @override
  String get dashboardEmptyBody => 'Vous pourrez ajouter de nouveau n\'importe quelle section quand vous le souhaitez.';

  @override
  String get dashboardCustomize => 'Personnaliser le tableau de bord';

  @override
  String get dashboardSectionQuickActionsTitle => 'Actions rapides';

  @override
  String get dashboardSectionQuickActionsBody => 'Consignez une mesure ou commencez un entraînement.';

  @override
  String get dashboardSectionTrainingTitle => 'Prêt à vous entraîner';

  @override
  String get dashboardSectionTrainingBody => 'Sélectionnez votre profil de gym, vos plans et commencez une séance.';

  @override
  String get dashboardSectionNutritionTitle => 'Tableau de bord nutrition';

  @override
  String get dashboardSectionNutritionBody => 'Consultez les cibles actuelles de calories et de macronutriments.';

  @override
  String get dashboardSectionDataRecordsTitle => 'Données et relevés';

  @override
  String get dashboardSectionDataRecordsBody => 'Consultez et ajoutez les entrées quotidiennes de nutrition.';

  @override
  String get dashboardSectionWeeklyFocusTitle => 'Focus hebdomadaire';

  @override
  String get dashboardSectionWeeklyFocusBody => 'Consultez le travail des parties du corps et des muscles des 7 derniers jours.';

  @override
  String get dashboardSectionWorkoutReportTitle => 'Rapport d\'entraînement';

  @override
  String get dashboardSectionWorkoutReportBody => 'Comparez au fil du temps le nombre d\'entraînements, la durée et le volume.';

  @override
  String get dashboardSectionExerciseProgressTitle => 'Progrès des exercices';

  @override
  String get dashboardSectionExerciseProgressBody => 'Suivez les tendances de force pour les exercices sélectionnés.';

  @override
  String get dashboardSectionHistoryTitle => 'Historique d\'entraînement';

  @override
  String get dashboardSectionHistoryBody => 'Comparez les totaux et le focus des entraînements selon différentes périodes.';

  @override
  String get dashboardSectionHealthTrendsTitle => 'Tendances de santé';

  @override
  String get dashboardSectionHealthTrendsBody => 'Suivez des mesures comme le poids et les mensurations.';

  @override
  String get dashboardSectionRecentWorkoutsTitle => 'Entraînements récents';

  @override
  String get dashboardSectionRecentWorkoutsBody => 'Ouvrez vos dernières séances terminées.';

  @override
  String get dashboardSectionActivePlansTitle => 'Plans actifs';

  @override
  String get dashboardSectionActivePlansBody => 'Gardez vos plans les plus utilisés à portée de main.';

  @override
  String get dashboardSectionArchivedPlansTitle => 'Plans archivés';

  @override
  String get dashboardSectionArchivedPlansBody => 'Parcourez les plans qui ne sont pas actifs actuellement.';

  @override
  String get dashboardSectionPremadePlansTitle => 'Plans préfabriqués';

  @override
  String get dashboardSectionPremadePlansBody => 'Parcourez les routines pouvant être ajoutées à ce profil.';

  @override
  String get dashboardSectionPlanToolsTitle => 'Outils de planification';

  @override
  String get dashboardSectionPlanToolsBody => 'Générez un plan équilibré ou créez-en un manuellement.';

  @override
  String get dashboardSectionCatalogTitle => 'Catalogue d\'exercices';

  @override
  String get dashboardSectionCatalogBody => 'Ouvrez vos exercices les plus utilisés et le catalogue complet.';

  @override
  String get dashboardSectionAnatomyTitle => 'Anatomie ciblée';

  @override
  String get dashboardSectionAnatomyBody => 'Consultez les parties du corps et les muscles que vous entraînez le plus.';

  @override
  String get dashboardSectionFallbackTitle => 'Section du tableau de bord';

  @override
  String get dashboardSectionFallbackBody => 'Une section du tableau de bord.';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get dashboardDoneCustomizing => 'Terminer la personnalisation';

  @override
  String get dashboardQuickActions => 'Actions rapides';

  @override
  String get dashboardMeasurement => 'Mesure';

  @override
  String get dashboardResumeWorkout => 'Reprendre l\'entraînement';

  @override
  String get dashboardStartWorkout => 'Commencer l\'entraînement';

  @override
  String dashboardTodayAt(String time) {
    return 'Aujourd\'hui, $time';
  }

  @override
  String get dashboardRecentWorkouts => 'Entraînements récents';

  @override
  String get dashboardViewAll => 'Voir tout';

  @override
  String get dashboardRecentWorkoutsFailed => 'Impossible de charger les entraînements récents.';

  @override
  String get dashboardRecentWorkoutsEmpty => 'Terminez un entraînement et il apparaîtra ici.';

  @override
  String get userInfoProfileUpdateNote => 'Mise à jour du profil';

  @override
  String get userInfoChangesSaved => 'Modifications enregistrées';

  @override
  String get userInfoSaveFailed => 'Impossible d\'enregistrer vos modifications.';

  @override
  String get userInfoTitle => 'Informations utilisateur';

  @override
  String get userInfoSubtitle => 'Conservez les renseignements de base du profil pour les calculs de l\'application.';

  @override
  String get userInfoIdentityTitle => 'Identité';

  @override
  String get userInfoIdentitySubtitle => 'Renseignements personnels de base.';

  @override
  String get userInfoName => 'Nom';

  @override
  String get userInfoNameHint => 'Entrez votre nom';

  @override
  String get userInfoGender => 'Genre';

  @override
  String get userInfoDateOfBirth => 'Date de naissance';

  @override
  String get userInfoDateHint => 'AAAA-MM-JJ';

  @override
  String get userInfoBodyMetricsTitle => 'Mesures corporelles';

  @override
  String get userInfoBodyMetricsSubtitle => 'Détails facultatifs utilisés pour les estimations de progrès et de nutrition.';

  @override
  String get userInfoHeight => 'Taille';

  @override
  String get userInfoHeightHint => 'p. ex. 5\'10\" ou 178 cm';

  @override
  String get userInfoCurrentWeight => 'Poids actuel';

  @override
  String get userInfoWeightPoundsHint => 'p. ex. 160';

  @override
  String get userInfoWeightKilogramsHint => 'p. ex. 72';

  @override
  String get userInfoBodyFat => 'Estimation du % de gras corporel';

  @override
  String get userInfoActivityTitle => 'Contexte d\'activité';

  @override
  String get userInfoActivitySubtitle => 'Utilisé plus tard pour les recommandations et les estimations de santé.';

  @override
  String get userInfoWeightTrend => 'Tendance du poids';

  @override
  String get userInfoAverageSteps => 'Moyenne estimée des pas';

  @override
  String get userInfoGenderMale => 'Homme';

  @override
  String get userInfoGenderFemale => 'Femme';

  @override
  String get userInfoGenderOther => 'Autre';

  @override
  String get userInfoGenderPreferNotToSay => 'Préfère ne pas répondre';

  @override
  String get userInfoTrendGaining => 'Prise de poids';

  @override
  String get userInfoTrendLosing => 'Perte de poids';

  @override
  String get userInfoTrendMaintaining => 'Maintien du poids';

  @override
  String get userInfoTrendNotSure => 'Incertain';

  @override
  String get userInfoActivityLow => 'Faible (0-5k)';

  @override
  String get userInfoActivityModerate => 'Modérée (5-15k)';

  @override
  String get userInfoActivityHigh => 'Élevée (15k+)';

  @override
  String get userInfoSaveChanges => 'Enregistrer les modifications';

  @override
  String get tutorialsSettingsTitle => 'Tutoriels guidés';

  @override
  String get tutorialsSettingsSubtitle => 'Rejouez une visite guidée lorsque vous souhaitez un rappel rapide.';

  @override
  String get tutorialsControlsTitle => 'Contrôles des tutoriels';

  @override
  String get tutorialsControlsSubtitle => 'Vous faites des tests ou recommencez?';

  @override
  String get tutorialsResetAllTitle => 'Réinitialiser tous les tutoriels';

  @override
  String get tutorialsResetAllSubtitle => 'Rend tous les tutoriels guidés accessibles de nouveau.';

  @override
  String get tutorialsResetAll => 'Tout réinitialiser';

  @override
  String get tutorialsResetAllMessage => 'Tous les tutoriels ont été réinitialisés.';

  @override
  String get tutorialsHowItWorksTitle => 'Fonctionnement des tutoriels';

  @override
  String get tutorialsHowItWorksBody => 'Les tutoriels apparaissent une fois, puis ne vous encombrent plus. Développez un groupe pour réinitialiser une visite précise.';

  @override
  String get tutorialsMainTabsTitle => 'Onglets principaux';

  @override
  String get tutorialsMainTabsSubtitle => 'Rejouez les visites guidées de chaque zone principale.';

  @override
  String get tutorialsWorkoutTitle => 'Entraînement';

  @override
  String get tutorialsWorkoutSubtitle => 'Aide pour consigner votre première séance.';

  @override
  String get tutorialsPlansTitle => 'Plans et entraînements';

  @override
  String get tutorialsPlansSubtitle => 'Rejouez l\'aide pour créer, modifier et consulter les entraînements.';

  @override
  String get tutorialsCatalogTitle => 'Catalogue et anatomie';

  @override
  String get tutorialsCatalogSubtitle => 'Rejouez l\'aide sur les exercices et l\'anatomie ciblée.';

  @override
  String get tutorialsProgressTitle => 'Progrès et réglages';

  @override
  String get tutorialsProgressSubtitle => 'Rejouez l\'aide sur les détails de progrès et les pages de réglages.';

  @override
  String tutorialsReplayTitle(String topic) {
    return 'Rejouer le tutoriel : $topic';
  }

  @override
  String tutorialsShownNextTime(String topic) {
    return 'S\'affichera la prochaine fois que vous ouvrirez $topic.';
  }

  @override
  String tutorialsWillReplayNextTime(String topic) {
    return 'Le tutoriel $topic sera rejoué la prochaine fois.';
  }

  @override
  String get tutorialsReset => 'Réinitialiser';

  @override
  String get tutorialsTopicTrain => 'Entraîner';

  @override
  String get tutorialsTopicCatalog => 'Catalogue';

  @override
  String get tutorialsTopicLogbook => 'Journal';

  @override
  String get tutorialsTopicProgress => 'Progrès';

  @override
  String get tutorialsTopicProfile => 'Profil';

  @override
  String get tutorialsTopicFirstWorkout => 'premier entraînement';

  @override
  String get tutorialsTopicGeneratePlans => 'Générer des plans';

  @override
  String get tutorialsTopicOptimizedSettings => 'réglages d\'entraînement optimisé';

  @override
  String get tutorialsTopicPremadePlans => 'Plans préfabriqués';

  @override
  String get tutorialsTopicPlanManagement => 'gestion des plans';

  @override
  String get tutorialsTopicPlanDetail => 'détails du plan';

  @override
  String get tutorialsTopicPlanBuilder => 'créateur de plan';

  @override
  String get tutorialsTopicWorkoutDetail => 'détails de l\'entraînement';

  @override
  String get tutorialsTopicExerciseCatalog => 'Catalogue d\'exercices';

  @override
  String get tutorialsTopicExerciseDetail => 'détails de l\'exercice';

  @override
  String get tutorialsTopicTargetAnatomy => 'Anatomie ciblée';

  @override
  String get tutorialsTopicBodypartDetail => 'détails de la partie du corps';

  @override
  String get tutorialsTopicMuscleDetail => 'détails du muscle';

  @override
  String get tutorialsTopicWeeklySets => 'Aperçu hebdomadaire des séries';

  @override
  String get tutorialsTopicExerciseProgress => 'progrès de l\'exercice';

  @override
  String get tutorialsTopicMeasurementTrend => 'tendance de mesure';

  @override
  String get tutorialsTopicGymProfile => 'éditeur de profil de gym';

  @override
  String get tutorialsTopicUiAppearance => 'Interface et apparence';

  @override
  String get tutorialsTopicDatabaseSettings => 'Réglages de la base de données';

  @override
  String get tutorialsTopicGuide => 'aide guidée';

  @override
  String get anatomyLibraryTitle => 'Bibliothèque de ciblage des exercices';

  @override
  String get anatomyBodyParts => 'Parties du corps';

  @override
  String get anatomyMuscles => 'Muscles';

  @override
  String get anatomyLoadFailed => 'Impossible de charger les filtres anatomiques.';

  @override
  String get anatomySearchLabel => 'Rechercher des parties du corps ou des muscles';

  @override
  String get anatomyNoBodyParts => 'Aucune partie du corps ne correspond à votre recherche.';

  @override
  String get anatomyNoMuscles => 'Aucun muscle ne correspond à votre recherche.';

  @override
  String anatomyExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercices',
      one: '1 exercice',
    );
    return '$_temp0';
  }

  @override
  String get anatomyTutorialSearchTitle => 'Rechercher l\'anatomie';

  @override
  String get anatomyTutorialSearchBody => 'Recherchez une partie du corps ou un muscle précis lorsque vous souhaitez des options d\'exercice ciblées.';

  @override
  String get anatomyTutorialListsTitle => 'Parties du corps et muscles';

  @override
  String get anatomyTutorialListsBody => 'Changez d\'onglet, puis touchez une ligne pour voir les exercices associés, les totaux récents et les limites de séries recommandées.';

  @override
  String anatomyTargetExercises(String name) {
    return 'Exercices : $name';
  }

  @override
  String get anatomyBodypartLoadFailed => 'Impossible de charger cette partie du corps.';

  @override
  String get anatomyMuscleLoadFailed => 'Impossible de charger ce muscle.';

  @override
  String anatomyRecommendedSetsUpdated(String name) {
    return 'Les séries recommandées pour $name ont été mises à jour.';
  }

  @override
  String get anatomySaveFailed => 'Impossible d\'enregistrer les modifications.';

  @override
  String anatomyLinkedExerciseCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count exercices associés',
      one: '1 exercice associé',
    );
    return '$_temp0';
  }

  @override
  String get anatomyDoneLastSevenDays => 'Effectué (7 jours)';

  @override
  String get anatomySetsLastSevenDays => 'Séries des 7 derniers jours';

  @override
  String anatomySetUnits(String count) {
    return '$count séries';
  }

  @override
  String get anatomyRecommended => 'Recommandé';

  @override
  String get anatomyNotSet => 'Non défini';

  @override
  String anatomySetRange(String min, String max) {
    return '$min-$max séries';
  }

  @override
  String get anatomyAssociatedMuscles => 'Muscles associés';

  @override
  String get anatomyRelatedBodyParts => 'Parties du corps associées';

  @override
  String get anatomyNoMuscleLinks => 'Aucun muscle n\'est encore associé à cette partie du corps.';

  @override
  String get anatomyNoBodyPartLinks => 'Aucune partie du corps n\'est encore associée à ce muscle.';

  @override
  String get anatomyExercises => 'Exercices';

  @override
  String anatomyNoExercisesFor(String name) {
    return 'Aucun exercice n\'est actuellement associé à $name.';
  }

  @override
  String get anatomyNoEquipment => 'Aucun équipement indiqué';

  @override
  String get anatomyNoMusclesListed => 'Aucun muscle indiqué';

  @override
  String get anatomyNoBodyPartsListed => 'Aucune partie du corps indiquée';

  @override
  String anatomyOpenedFrom(String name) {
    return 'Ouvert depuis $name';
  }

  @override
  String anatomyRankForMuscle(int rank, String bodyparts) {
    return 'Rang $rank pour ce muscle - $bodyparts';
  }

  @override
  String get anatomyTutorialDetailTitle => 'Détails anatomiques';

  @override
  String get anatomyTutorialBodypartDetailBody => 'L\'en-tête présente les séries récentes, les limites recommandées et les liens anatomiques associés.';

  @override
  String get anatomyTutorialMuscleDetailTitle => 'Détails du muscle';

  @override
  String get anatomyTutorialMuscleDetailBody => 'L\'en-tête présente les séries récentes, les limites recommandées et les parties du corps associées.';

  @override
  String get anatomyTutorialLinkedExercisesTitle => 'Exercices associés';

  @override
  String get anatomyTutorialBodypartExercisesBody => 'Voici les exercices liés à cette cible. Touchez-en un pour ouvrir tous ses détails.';

  @override
  String get anatomyTutorialMuscleExercisesBody => 'Les exercices sont classés selon la façon dont ils travaillent directement ce muscle. Touchez-en un pour voir tous les détails.';

  @override
  String get settingsWorkoutTitle => 'Réglages d\'entraînement';

  @override
  String get settingsWorkoutSubtitle => 'Ajustez la façon dont l\'application interprète l\'anatomie, les priorités et les objectifs de volume.';

  @override
  String get settingsTrainingBiasTitle => 'Priorités d\'entraînement';

  @override
  String get settingsTrainingBiasSubtitle => 'Contrôles utilisés par les plans générés et les séances optimisées.';

  @override
  String get settingsBodyPartRankings => 'Classement des parties du corps';

  @override
  String get settingsBodyPartRankingsSubtitle => 'Priorisez les parties du corps qui devraient recevoir plus de travail.';

  @override
  String get settingsMuscleRankings => 'Classement des muscles';

  @override
  String get settingsMuscleRankingsSubtitle => 'Priorisez les muscles précis du modèle anatomique.';

  @override
  String get settingsVolumeBoundaries => 'Limites de volume';

  @override
  String get settingsVolumeBoundariesSubtitle => 'Définissez les plages hebdomadaires recommandées pour les parties du corps et les muscles.';

  @override
  String get settingsExerciseDefinitionsTitle => 'Définitions des exercices';

  @override
  String get settingsExerciseDefinitionsSubtitle => 'Gérez les données d\'anatomie et d\'exercices utilisées par l\'application.';

  @override
  String get settingsAnatomyMapping => 'Association parties du corps / muscles';

  @override
  String get settingsAnatomyMappingSubtitle => 'Choisissez les muscles associés à chaque partie du corps.';

  @override
  String get settingsExerciseSetAllocation => 'Répartition des séries par exercice';

  @override
  String get settingsExerciseSetAllocationSubtitle => 'Examinez la contribution de chaque exercice aux muscles et aux parties du corps.';

  @override
  String get settingsExerciseEditor => 'Éditeur d\'exercices';

  @override
  String get settingsExerciseEditorSubtitle => 'Modifiez les noms, détails, équipements et associations des exercices.';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonImport => 'Importer';

  @override
  String get commonExport => 'Exporter';

  @override
  String get databaseExportTitle => 'Exporter la base de données';

  @override
  String get databaseImportTitle => 'Importer la base de données';

  @override
  String get databasePasteJson => 'Collez le JSON ici';

  @override
  String get databaseCopied => 'Copié dans le presse-papiers';

  @override
  String databaseExportFailed(String error) {
    return 'Echec de l\'export : $error';
  }

  @override
  String get databaseImportSucceeded => 'Importation réussie';

  @override
  String databaseImportFailed(String error) {
    return 'Echec de l\'import : $error';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get nutritionSettingsTitle => 'Réglages de l\'alimentation et de la nutrition';

  @override
  String get nutritionSettingsSubtitle => 'Configurez les objectifs nutritionnels et les préférences alimentaires.';

  @override
  String get nutritionCurrentGoals => 'Objectifs actuels';

  @override
  String get nutritionGoals => 'Objectifs';

  @override
  String get nutritionGoalsSubtitle => 'Définissez les cibles utilisées par le suivi nutritionnel.';

  @override
  String get nutritionManualGoals => 'Définir manuellement les objectifs nutritionnels';

  @override
  String get nutritionManualGoalsSubtitle => 'Saisissez vous-même les calories, macronutriments et nutriments clés.';

  @override
  String get nutritionGoalsSaved => 'Objectifs enregistrés';

  @override
  String nutritionGoalSummary(String calories, String protein, String carbs, String fat, String fiber, String sugar, String satFat, String sodium) {
    return 'Calories : $calories / Protéines : $protein / Glucides : $carbs / Lipides : $fat / Fibres : $fiber / Sucre : $sugar / Gras sat. : $satFat / Sodium : $sodium';
  }

  @override
  String get progressSettingsTitle => 'Réglages de progression';

  @override
  String get progressSettingsSubtitle => 'Gérez les mesures corporelles et le suivi des tendances.';

  @override
  String get progressMeasurements => 'Mesures';

  @override
  String get progressMeasurementsSubtitle => 'Configurez les mesures corporelles que vous souhaitez suivre au fil du temps.';

  @override
  String get progressMeasurementLibrary => 'Bibliothèque de mesures';

  @override
  String get progressMeasurementLibrarySubtitle => 'Gérez le poids, la taille, les mensurations et les mesures personnalisées.';

  @override
  String get nutritionManualGoalsTitle => 'Objectifs nutritionnels manuels';

  @override
  String get nutritionManualGoalsPageSubtitle => 'Définissez manuellement les cibles de calories, macronutriments et nutriments.';

  @override
  String get nutritionSaveGoals => 'Enregistrer les objectifs';

  @override
  String get nutritionSaving => 'Enregistrement...';

  @override
  String get nutritionStartDate => 'Date de début';

  @override
  String get nutritionGoalStarts => 'Début de l\'objectif';

  @override
  String get nutritionCaloriesAndMacros => 'Calories et macronutriments';

  @override
  String get nutritionAdditionalNutrients => 'Nutriments supplémentaires';

  @override
  String get nutritionCalories => 'Calories (kcal)';

  @override
  String get nutritionProtein => 'Protéines (g)';

  @override
  String get nutritionCarbs => 'Glucides (g)';

  @override
  String get nutritionFat => 'Lipides (g)';

  @override
  String get nutritionFiber => 'Fibres (g)';

  @override
  String get nutritionSugar => 'Sucre (g)';

  @override
  String get nutritionSatFat => 'Gras sat. (g)';

  @override
  String get nutritionSodium => 'Sodium (mg)';

  @override
  String get nutritionEnterNumber => 'Saisissez un nombre';

  @override
  String get nutritionNumberAtLeastZero => 'La valeur doit être supérieure ou égale à 0';

  @override
  String rankingsSaved(String target) {
    return 'Classement de $target enregistré';
  }

  @override
  String get rankingsSave => 'Enregistrer le classement';

  @override
  String rankingsTitle(String target) {
    return 'Classement des $target';
  }

  @override
  String rankingsHero(String target) {
    return 'Faites glisser les $target dans l\'ordre que les entraînements générés devraient privilégier.';
  }

  @override
  String get rankingsNoBodyParts => 'Aucune partie du corps définie';

  @override
  String get rankingsNoMuscles => 'Aucun muscle défini';

  @override
  String rankingsLoadError(String target, String error) {
    return 'Impossible de charger $target : $error';
  }

  @override
  String rankingsSaveError(String error) {
    return 'Impossible d\'enregistrer : $error';
  }

  @override
  String get rankingsRank => 'Rang';

  @override
  String get mappingTitle => 'Association anatomique';

  @override
  String get mappingHero => 'Associez les muscles aux parties du corps pour que les cartes thermiques, les analyses et les entraînements générés soient cohérents.';

  @override
  String get mappingSaved => 'Associations enregistrées';

  @override
  String mappingSaveFailed(String error) {
    return 'Impossible d\'enregistrer : $error';
  }

  @override
  String get mappingSelectedBodyPart => 'Partie du corps sélectionnée';

  @override
  String get mappingBodyPart => 'Partie du corps';

  @override
  String get mappingChooseLinkedMuscles => 'Choisir les muscles associés';

  @override
  String get mappingLinkedMuscles => 'Muscles associés';

  @override
  String get mappingChooseLinkedSubtitle => 'Sélectionnez chaque muscle appartenant à cette partie du corps.';

  @override
  String mappingLinkedCount(int count) {
    return '$count muscles actuellement associés.';
  }

  @override
  String get mappingNoMuscles => 'Aucun muscle défini.';

  @override
  String get mappingNoLinkedMuscles => 'Aucun muscle associé pour le moment. Touchez Modifier pour en ajouter.';

  @override
  String get volumeMaintenance => 'Entretien';

  @override
  String get volumeMinEffective => 'Minimum efficace';

  @override
  String get volumeMaxAdaptive => 'Maximum adaptatif';

  @override
  String get volumeMaxRecoverable => 'Maximum récupérable';

  @override
  String volumeLoadBodyPartFailed(String error) {
    return 'Impossible de charger les limites de cette partie du corps : $error';
  }

  @override
  String volumeLoadMuscleFailed(String error) {
    return 'Impossible de charger les limites de ce muscle : $error';
  }

  @override
  String get volumeBodyPartSaved => 'Limites de la partie du corps enregistrées';

  @override
  String get volumeMuscleSaved => 'Limites du muscle enregistrées';

  @override
  String get volumeInvalidNumbers => 'Saisissez des nombres valides';

  @override
  String get volumeBodyParts => 'Parties du corps';

  @override
  String get volumeMuscles => 'Muscles';

  @override
  String get volumeBodyPartTitle => 'Volume par partie du corps';

  @override
  String get volumeBodyPartSubtitle => 'Définissez les plages hebdomadaires utilisées par les analyses et la génération d\'entraînements.';

  @override
  String get volumeMuscleTitle => 'Volume par muscle';

  @override
  String get volumeMuscleSubtitle => 'Affinez les plages hebdomadaires pour chaque muscle.';

  @override
  String get volumeSelection => 'Sélection';

  @override
  String get volumeRecommendedRange => 'Plage recommandée';

  @override
  String get volumeRecommendedRangeSubtitle => 'Les nombres sont des unités de séries par semaine.';

  @override
  String get volumeSaveBoundaries => 'Enregistrer les limites';

  @override
  String get nutritionDashboardTitle => 'Tableau de bord nutritionnel';

  @override
  String nutritionDashboardError(String error) {
    return 'Impossible de charger la nutrition : $error';
  }

  @override
  String get nutritionMenuTitle => 'Menu nutrition';

  @override
  String get nutritionLogFood => 'Consigner un aliment';

  @override
  String get nutritionTrackMeasurement => 'Consigner une mesure';

  @override
  String get nutritionMeasuredItems => 'Mesures suivies';

  @override
  String get nutritionTodayRecords => 'Données du jour';

  @override
  String get nutritionGoalsMenu => 'Objectifs nutritionnels';

  @override
  String get measurementWeight => 'Poids';

  @override
  String get measurementHips => 'Hanches';

  @override
  String get measurementShoulders => 'Épaules';

  @override
  String get measurementCalves => 'Mollets';

  @override
  String get measurementTrackNew => 'Suivre une nouvelle mesure';

  @override
  String get barcodeScannerTitle => 'Numériser un code-barres';

  @override
  String get barcodeSwitchCamera => 'Changer de caméra';

  @override
  String get barcodeTorchOn => 'Allumer la lampe';

  @override
  String get barcodeTorchOff => 'Éteindre la lampe';

  @override
  String get barcodeTorchUnavailable => 'La lampe n\'est pas disponible sur cet appareil';

  @override
  String get barcodeAlignHint => 'Alignez le code-barres dans le cadre';

  @override
  String get progressTutorialWorkoutReportTitle => 'Rapport d\'entraînement';

  @override
  String get progressTutorialWorkoutReportBody => 'Ce rapport suit le nombre d\'entraînements, le temps d\'entraînement et le volume sur différentes périodes. Touchez une mesure pour modifier le graphique.';

  @override
  String get progressTutorialExerciseProgressTitle => 'Progression des exercices';

  @override
  String get progressTutorialExerciseProgressBody => 'Suivez les tendances de force des exercices sélectionnés. Utilisez la tuile Modifier pour ajouter ou retirer des exercices de ce tableau de bord.';

  @override
  String get progressTutorialHealthTrendsTitle => 'Tendances de santé';

  @override
  String get progressTutorialHealthTrendsBody => 'Consignez le poids corporel et les mesures personnalisées ici, puis observez leur évolution au fil du temps.';

  @override
  String get measurementNewTitle => 'Nouvelle mesure';

  @override
  String get measurementPresets => 'Préréglages';

  @override
  String get measurementCustom => 'Personnalisé';

  @override
  String get measurementPresetType => 'Type préréglé';

  @override
  String get measurementVariation => 'Variation';

  @override
  String get measurementWakeUp => 'Au réveil';

  @override
  String get measurementBedtime => 'Au coucher';

  @override
  String get measurementOverall => 'Global';

  @override
  String get measurementValueWeight => 'Poids';

  @override
  String get measurementUnits => 'Unités';

  @override
  String get measurementFeet => 'Pieds';

  @override
  String get measurementInches => 'Pouces';

  @override
  String get measurementCentimeters => 'Centimètres';

  @override
  String get measurementWithPump => 'Avec congestion';

  @override
  String get measurementWithoutPump => 'Sans congestion';

  @override
  String get measurementName => 'Nom de la mesure';

  @override
  String get measurementNameHint => 'Tour de poitrine, fréquence cardiaque au repos...';

  @override
  String get measurementValue => 'Valeur';

  @override
  String get measurementUnit => 'Unité';

  @override
  String get measurementNote => 'Note';

  @override
  String get measurementOptional => 'Facultatif';

  @override
  String get measurementSaveNew => 'Enregistrer la nouvelle mesure';

  @override
  String get measurementCustomRequired => 'Saisissez un nom, une valeur et une unité personnalisés';

  @override
  String measurementDefinitionNotFound(String name) {
    return 'Définition introuvable pour $name';
  }

  @override
  String get measurementInvalidValue => 'Saisissez une valeur numérique valide';

  @override
  String get measurementHeight => 'Taille';

  @override
  String get measurementForearm => 'Avant-bras';

  @override
  String get measurementArm => 'Bras';

  @override
  String get measurementNeck => 'Cou';

  @override
  String get measurementChest => 'Poitrine';

  @override
  String get measurementWaist => 'Taille';

  @override
  String get measurementThigh => 'Cuisse';

  @override
  String get measurementInstructionsForearm => 'Mesurez autour de la partie la plus large de votre avant-bras.';

  @override
  String get measurementInstructionsArm => 'Mesurez autour de la partie la plus large de votre biceps.';

  @override
  String get measurementInstructionsNeck => 'Mesurez à l\'endroit où le ruban repose droit autour de votre cou.';

  @override
  String get measurementInstructionsShoulder => 'Gardez le ruban droit autour des deltoïdes latéraux.';

  @override
  String get measurementInstructionsChest => 'Mesurez sous les aisselles et au-dessus de la ligne des mamelons.';

  @override
  String get measurementInstructionsWaist => 'Mesurez autour de votre nombril.';

  @override
  String get measurementInstructionsHip => 'Mesurez autour de la partie la plus large de vos fessiers.';

  @override
  String get measurementInstructionsThigh => 'Mesurez autour de la partie la plus large de votre cuisse.';

  @override
  String get measurementInstructionsCalf => 'Mesurez autour de la partie la plus large de votre mollet.';

  @override
  String get nutritionCaloriesLabel => 'Calories';

  @override
  String get nutritionFatLabel => 'Lipides';

  @override
  String get nutritionProteinLabel => 'Protéines';

  @override
  String get nutritionCarbsLabel => 'Glucides';

  @override
  String nutritionMacroSummary(int calories, int protein, int carbs, int fat) {
    return '$calories kcal | P $protein g | G $carbs g | L $fat g';
  }

  @override
  String get nutritionEditEntry => 'Modifier l\'entrée';

  @override
  String get nutritionEditNotAvailable => 'La modification des entrées n\'est pas encore disponible';

  @override
  String get nutritionEntryDeleted => 'Entrée supprimée';

  @override
  String get gymProfileEditTitle => 'Modifier le profil de gym';

  @override
  String get gymProfileNewTitle => 'Nouveau profil de gym';

  @override
  String get gymProfileTutorialSpaceTitle => 'Espace d\'entraînement';

  @override
  String get gymProfileTutorialSpaceBody => 'Nommez ce profil selon l\'endroit où vous vous entraînez, comme Gym à domicile, Gym commercial ou Installation de voyage.';

  @override
  String get gymProfileTutorialFindTitle => 'Trouver de l\'équipement';

  @override
  String get gymProfileTutorialFindBody => 'Utilisez la recherche lorsque la liste est longue pour accéder rapidement à un article.';

  @override
  String get gymProfileTutorialAvailableTitle => 'Équipement disponible';

  @override
  String get gymProfileTutorialAvailableBody => 'Sélectionnez l\'équipement de cet espace. Les plans générés et les remplacements l\'utilisent pour éviter les exercices indisponibles.';

  @override
  String get gymProfileTutorialSaveTitle => 'Enregistrer le profil';

  @override
  String get gymProfileTutorialSaveBody => 'Enregistrer sauvegarde le profil et l\'équipement. Annuler demande avant d\'ignorer les modifications.';

  @override
  String get gymProfileSaveChangesTitle => 'Enregistrer les modifications?';

  @override
  String get gymProfileSaveChangesBody => 'Ce profil de gym contient des modifications non enregistrées. Les enregistrer avant de quitter?';

  @override
  String get gymProfileKeepEditing => 'Continuer la modification';

  @override
  String get gymProfileDiscard => 'Ignorer';

  @override
  String get gymProfileSelectEquipment => 'Sélectionnez au moins un article d\'équipement.';

  @override
  String gymProfileSaveFailed(String error) {
    return 'Impossible d\'enregistrer le profil : $error';
  }

  @override
  String get gymProfileEquipmentHint => 'Indiquez l\'équipement de ce gym pour que les plans générés n\'utilisent que des exercices disponibles.';

  @override
  String get gymProfileSpace => 'Espace d\'entraînement';

  @override
  String gymProfileEquipmentSelected(int selected, int total) {
    return '$selected options sur $total sélectionnées';
  }

  @override
  String get gymProfileName => 'Nom du profil';

  @override
  String get gymProfileNameHint => 'Gym à domicile, gym commercial, installation de voyage...';

  @override
  String get gymProfileNameRequired => 'Le nom est requis';

  @override
  String get gymProfileFilterEquipment => 'Filtrer l\'équipement par nom';

  @override
  String get gymProfileEquipment => 'Équipement';

  @override
  String get gymProfileSelectAll => 'Tout sélectionner';

  @override
  String get gymProfileClear => 'Effacer';

  @override
  String gymProfileSelectedCount(int selected, int total) {
    return '$selected/$total sélectionnés';
  }

  @override
  String get gymProfileSave => 'Enregistrer le profil';

  @override
  String get gymProfileSaving => 'Enregistrement...';

  @override
  String gymProfileNoEquipmentMatch(String query) {
    return 'Aucun équipement ne correspond à « $query ».';
  }

  @override
  String get equipmentCategoryBasics => 'Essentiels';

  @override
  String get equipmentCategoryFreeWeights => 'Poids libres';

  @override
  String get equipmentCategoryBenchesRacks => 'Bancs et supports';

  @override
  String get equipmentCategoryCableAttachments => 'Câbles et accessoires';

  @override
  String get equipmentCategoryMachines => 'Machines';

  @override
  String get equipmentCategoryOther => 'Autre équipement';

  @override
  String get equipmentNoRequirement => 'Aucun équipement requis';

  @override
  String get equipmentBodyweightSupport => 'Support pour exercices au poids du corps';

  @override
  String get equipmentMachineBased => 'Mouvement sur machine';

  @override
  String get equipmentCableAccessory => 'Accessoire de station à câbles';

  @override
  String get equipmentBenchRackSetup => 'Banc, support ou station';

  @override
  String get equipmentFreeWeightTraining => 'Entraînement avec poids libres';

  @override
  String get equipmentAvailable => 'Équipement disponible';

  @override
  String get foodLoggingTitle => 'Consignation des aliments';

  @override
  String get foodLogTime => 'Heure de consignation :';

  @override
  String get foodPortion => 'Portion :';

  @override
  String get foodQuantity => 'Qté :';

  @override
  String foodGramsPerUnit(int grams) {
    return '$grams g / unité';
  }

  @override
  String get foodRemove => 'Retirer';

  @override
  String get foodAddAllToDiary => 'Ajouter le tout au journal';

  @override
  String get foodLogging => 'Ajout...';

  @override
  String get foodTabScan => 'Numériser';

  @override
  String get foodTabSearch => 'Rechercher';

  @override
  String get foodTabPlanned => 'Planifié';

  @override
  String get foodTabCustom => 'Personnalisé';

  @override
  String get foodSearchHint => 'Rechercher un aliment...';

  @override
  String get foodNoRecentRecipes => 'Aucune recette récente.';

  @override
  String get foodRecentRecipe => 'Recette récente';

  @override
  String get foodNoFoodsFound => 'Aucun aliment trouvé.';

  @override
  String get foodInstantLogAfterScan => 'Consigner immédiatement après numérisation';

  @override
  String get foodInstantLogAfterScanSubtitle => 'Ajoutez immédiatement l\'article numérisé au repas sélectionné.';

  @override
  String get foodOpenCameraScanner => 'Ouvrir le numériseur photo';

  @override
  String get foodEnterBarcode => 'Saisir le code-barres manuellement';

  @override
  String get foodEnterBarcodeHint => 'p. ex. 012345678905';

  @override
  String get foodLogByBarcode => 'Consigner par code-barres';

  @override
  String get foodNoBarcode => 'Aucun code-barres valide détecté';

  @override
  String get foodBarcodeLogged => 'Article du code-barres consigné';

  @override
  String foodFailed(String error) {
    return 'Échec : $error';
  }

  @override
  String get foodCustomSavedBarcode => 'Aliment personnalisé enregistré et code-barres associé';

  @override
  String get foodFavorites => 'Favoris';

  @override
  String get foodRecentFoods => 'Aliments récents';

  @override
  String get foodStartSearching => 'Commencez une recherche pour trouver des aliments.';

  @override
  String get foodFavorite => 'Ajouter aux favoris';

  @override
  String get foodUnfavorite => 'Retirer des favoris';

  @override
  String get foodCustomize => 'Personnaliser l\'aliment';

  @override
  String get foodEditAndAdd => 'Modifier et ajouter';

  @override
  String get foodAddOne => 'Ajouter 1';

  @override
  String get foodAddNew => 'Ajouter un nouvel aliment';

  @override
  String get foodCustomSaved => 'Aliment personnalisé enregistré';

  @override
  String get foodNoteOptional => 'Note (facultatif)';

  @override
  String get foodTagsHint => 'Balises (séparées par des virgules, p. ex. après l\'entraînement, riche en protéines)';

  @override
  String get foodAddToPlate => 'Ajouter à l\'assiette';

  @override
  String get foodProfileNotReady => 'Le profil n\'est pas encore prêt.';

  @override
  String get foodItemsLogged => 'Articles ajoutés au journal';

  @override
  String foodLogFailed(String error) {
    return 'Impossible de consigner : $error';
  }

  @override
  String get tutorialSkip => 'Passer';

  @override
  String get tutorialSkipAll => 'Tout passer';

  @override
  String get tutorialDone => 'Terminer';

  @override
  String get tutorialNext => 'Suivant';

  @override
  String get tutorialSkipAllTitle => 'Passer tous les tutoriels?';

  @override
  String get tutorialSkipAllBody => 'Cette action masque tous les tutoriels guides. Vous pouvez les reactiver a tout moment dans Parametres > Tutoriels guides en utilisant Reinitialiser tous les tutoriels.';

  @override
  String get tutorialKeep => 'Garder les tutoriels';

  @override
  String get tutorialSkipEverything => 'Tout passer';

  @override
  String get flowSelectNode => 'Choisir un noeud';

  @override
  String get flowSelectMethod => 'Choisir une methode';

  @override
  String get flowAddSuccess => '+ Reussite';

  @override
  String get flowAddFailure => '+ Echec';

  @override
  String get flowAddMethod => '+ Methode';

  @override
  String get flowRemoveMethod => '- Methode';

  @override
  String get flowNewEvent => 'Nouvel evenement';

  @override
  String get flowEventKey => 'Cle de l\'evenement';

  @override
  String get flowEventDisplayLabel => 'Libelle affiche (facultatif)';

  @override
  String get flowAddSuccessNode => 'Ajouter un noeud de reussite';

  @override
  String get flowAddFailureNode => 'Ajouter un noeud d\'echec';

  @override
  String get flowAddEvent => '+ Evenement';

  @override
  String get flowSelectEvent => 'Choisir un evenement';

  @override
  String get flowRemoveEvent => 'Retirer l\'evenement';

  @override
  String get drawerNavigation => 'Navigation';

  @override
  String get drawerOptionA => 'Option A';

  @override
  String get drawerOptionB => 'Option B';

  @override
  String get drawerOptionC => 'Option C';

  @override
  String get drawerGymProfiles => 'Profils d\'entrainement';

  @override
  String drawerSavedSpaces(int count) {
    return '$count espaces enregistres';
  }

  @override
  String drawerProfileActive(String name) {
    return '$name est actif';
  }

  @override
  String get drawerActiveProfile => 'Profil actif';

  @override
  String get drawerTapToSwitch => 'Toucher pour changer';

  @override
  String get drawerNewProfile => 'Nouveau profil';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get automaticSaving => 'Enregistrement...';

  @override
  String get automaticValuesTab => 'Valeurs';

  @override
  String get automaticMethodsTab => 'Methodes';

  @override
  String get automaticGlobalIncrement => 'Valeur globale d\'increment';

  @override
  String get automaticAutoSelect => 'Selection automatique';

  @override
  String get automaticManualSelect => 'Selection manuelle';

  @override
  String get automaticSkipFirstSet => 'Passer la premiere serie?';

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
    return 'Impossible d\'enregistrer les reglages : $error';
  }

  @override
  String get automaticIncrementWhen => 'Incrementer lorsque (sinon diminuer) :';

  @override
  String get automaticWeightTarget => 'Poids effectue >= poids cible';

  @override
  String get automaticRepsTarget => 'Repetitions effectuees >= repetitions cibles';

  @override
  String get automaticVolumeTarget => 'Volume effectue >= volume cible';

  @override
  String get automaticScopeLabel => 'Les reussites, echecs et ajustements sont comptes par :';

  @override
  String get automaticWorkoutSession => 'Seance d\'entrainement';

  @override
  String get automaticPerExercise => 'Par exercice';

  @override
  String get automaticPerSet => 'Par serie';

  @override
  String get automaticAdjustScope => 'Ajuster :';

  @override
  String get automaticAdjustOneSet => '1 serie';

  @override
  String get automaticAdjustAllSets => 'Toutes les series';

  @override
  String get weightExpandSets => 'Developper les series';

  @override
  String get weightCollapseSets => 'Reduire les series';

  @override
  String get weightDetails => 'Details';

  @override
  String get weightRemoveExerciseTitle => 'Retirer l\'exercice';

  @override
  String get weightRemoveExerciseBody => 'Voulez-vous vraiment retirer cet exercice?';

  @override
  String get weightSwapExercise => 'Remplacer l\'exercice';

  @override
  String get weightMakeChangeSet => 'Creer une serie modifiee';

  @override
  String weightSetLabel(int number) {
    return 'Serie $number';
  }

  @override
  String weightLabel(String unit) {
    return 'Poids ($unit)';
  }

  @override
  String get weightReps => 'Repetitions';

  @override
  String get weightRemoveSetTitle => 'Retirer la serie';

  @override
  String get weightRemoveSetBody => 'Voulez-vous vraiment retirer cette serie?';

  @override
  String weightChangeSetLabel(int number) {
    return 'Serie mod. $number';
  }

  @override
  String weightShortLabel(String unit) {
    return 'Pds ($unit)';
  }

  @override
  String get weightRemoveChangeSetTitle => 'Retirer la serie modifiee';

  @override
  String get weightRemoveChangeSetBody => 'Voulez-vous vraiment retirer cette serie modifiee?';

  @override
  String get weightAddChangeSet => 'Ajouter une serie modifiee';

  @override
  String get weightAddSet => 'Ajouter une serie';

  @override
  String get swapAlreadySelected => 'Cet exercice est deja selectionne.';

  @override
  String get swapNeedsProfileEquipment => 'Cet exercice exige de l\'equipement absent de ce profil.';

  @override
  String swapLoadFailed(Object error) {
    return 'Impossible de charger cet exercice de remplacement.';
  }

  @override
  String get swapCurrent => 'Actuel';

  @override
  String get swapReplacement => 'Remplacement';

  @override
  String get swapConfirm => 'Confirmer le remplacement';

  @override
  String get swapNoBodypartData => 'Aucune donnee de partie du corps.';

  @override
  String get swapLoadingSelected => 'Chargement de l\'exercice selectionne...';

  @override
  String get swapBrowseCatalog => 'Parcourir le catalogue d\'exercices';

  @override
  String get swapNoEquipment => 'Aucun equipement indique';

  @override
  String get swapTitle => 'Remplacer l\'exercice';

  @override
  String get swapFindingMatches => 'Recherche de correspondances pour les muscles et parties du corps...';

  @override
  String get swapChooseReplacement => 'Choisissez un remplacement similaire.';

  @override
  String get swapFilterProfileEquipment => 'Filtrer selon l\'equipement du profil';

  @override
  String get swapBodypartsHit => 'Parties du corps sollicitees';

  @override
  String swapMatch(int percent) {
    return 'Correspondance : $percent %';
  }

  @override
  String get swapNoReplacements => 'Aucun remplacement similaire trouve.';

  @override
  String get swapNoReplacementsBody => 'Cet exercice pourrait avoir besoin de davantage de donnees sur les muscles ou les parties du corps pour etre bien remplace.';

  @override
  String get premadePlansTitle => 'Plans predefinis';

  @override
  String get premadeTutorialLengthTitle => 'Duree du plan';

  @override
  String get premadeTutorialLengthBody => 'Passez entre les versions de 1 heure et de 2 heures. Les versions plus longues comportent plus d\'exercices et de series.';

  @override
  String get premadeTutorialEquipmentTitle => 'Equipement du profil';

  @override
  String get premadeTutorialEquipmentBody => 'Lorsque cette option est activee, Tonos remplace les exercices non disponibles par des options similaires compatibles avec votre profil d\'entrainement.';

  @override
  String get premadeTutorialLibraryTitle => 'Bibliotheque de plans';

  @override
  String get premadeTutorialLibraryBody => 'Ouvrez une repartition, previsualisez un plan, puis ajoutez-le a vos plans actifs pour le retrouver dans Entrainement.';

  @override
  String get premadeSelectProfile => 'Veuillez d\'abord choisir un profil d\'entrainement.';

  @override
  String premadePlanAdded(String name) {
    return '$name a ete ajoute aux plans actifs.';
  }

  @override
  String premadePlanAddFailed(String name, String error) {
    return 'Impossible d\'ajouter $name : $error';
  }

  @override
  String get premadeDescription => 'Copiez des routines creees par des entraineurs, des influenceurs ou Tonos dans vos propres plans. Une fois ajoutees, vous pouvez les modifier comme tout autre plan.';

  @override
  String get premadeDiscarding => 'Suppression...';

  @override
  String get premadeReviewPlans => 'Verifier les plans';

  @override
  String get allocationSaveChanges => 'Enregistrer les modifications';

  @override
  String get allocationSaving => 'Enregistrement';

  @override
  String get allocationInvalidCredit => 'Saisissez un nombre positif ou nul pour chaque credit.';

  @override
  String get allocationSaved => 'Repartition de l\'exercice enregistree.';

  @override
  String get allocationSaveFailed => 'Impossible d\'enregistrer la repartition de l\'exercice. Reessayez.';

  @override
  String get allocationSaveOrDiscard => 'Enregistrez ou abandonnez vos modifications avant de reinitialiser.';

  @override
  String get allocationTitle => 'Repartition des series par exercice';

  @override
  String get allocationSubtitle => 'Examinez comment les series terminees contribuent aux muscles et aux parties du corps cibles.';

  @override
  String get allocationHowTitle => 'Fonctionnement du credit de serie';

  @override
  String get allocationHowBody => 'Un muscle principal recoit habituellement 1,00 credit pour une serie terminee. Les muscles de soutien recoivent moins de credit. Cela guide les resumes anatomiques et les recommandations sans jamais modifier les series que vous consignez.';

  @override
  String allocationLoadFailed(String error) {
    return 'Impossible de charger les exercices. $error';
  }

  @override
  String get allocationNoExercises => 'Aucun exercice n\'est encore disponible.';

  @override
  String get allocationSelectedExercise => 'Exercice selectionne';

  @override
  String get allocationMuscleCredit => 'Credit musculaire';

  @override
  String get allocationBodypartCredit => 'Credit de partie du corps';

  @override
  String get allocationNoTargetMuscles => 'Aucun muscle cible';

  @override
  String get allocationNoBodypartMapping => 'Aucune correspondance de partie du corps';

  @override
  String get allocationReset => 'Reinitialiser';

  @override
  String get allocationCredit => 'Credit';

  @override
  String get allocationNoTargetMusclesBody => 'Cet exercice ne contient pas encore de donnees sur les muscles cibles.';

  @override
  String get allocationMuscleCreditBody => 'Modifiez une valeur pour creer une repartition personnelle. Elle sert aux resumes musculaires et a la repartition des parties du corps qui en decoule.';

  @override
  String get allocationNoBodypartMappingBody => 'Cet exercice ne contient pas encore de correspondance pour les parties du corps.';

  @override
  String get allocationBodypartCreditBody => 'Les valeurs automatiques sont derivees des muscles et de la correspondance anatomique. En modifier une cree une repartition personnelle directe par partie du corps.';

  @override
  String get healthTrendsTitle => 'Tendances de sante';

  @override
  String get healthMetric => 'Indicateur';

  @override
  String get healthUnableToLoad => 'Impossible de charger les mesures';

  @override
  String get healthNoMeasurements => 'Aucune mesure pour le moment';

  @override
  String get healthNoMeasurementsBody => 'Creez un indicateur pour commencer a suivre vos progres.';

  @override
  String get healthCreateMetric => 'Creer un indicateur';

  @override
  String healthLogMeasurement(String name) {
    return 'Consigner $name';
  }

  @override
  String healthEditMeasurement(String name) {
    return 'Modifier $name';
  }

  @override
  String get healthTutorialSummaryTitle => 'Resume de la mesure';

  @override
  String get healthTutorialSummaryBody => 'Consultez la derniere valeur, le changement depuis l\'entree precedente et le nombre de releves.';

  @override
  String get healthTutorialChartTitle => 'Graphique des tendances';

  @override
  String get healthTutorialChartBody => 'Le graphique montre comment cette mesure evolue a mesure que vous ajoutez des entrees.';

  @override
  String get healthTutorialEntriesTitle => 'Entrees';

  @override
  String get healthTutorialEntriesBody => 'Touchez une entree pour la modifier ou retirez celles qui ont ete ajoutees par erreur.';

  @override
  String get healthTutorialLogTitle => 'Consigner une entree';

  @override
  String get healthTutorialLogBody => 'Utilisez ce bouton pour ajouter une nouvelle mesure.';

  @override
  String get healthDeleteEntryTitle => 'Supprimer l\'entree?';

  @override
  String healthDeleteEntryBody(String value, String date) {
    return '$value du $date sera supprime.';
  }

  @override
  String get healthLogEntry => 'Consigner une entree';

  @override
  String healthLoadFailed(String error) {
    return 'Impossible de charger : $error';
  }

  @override
  String get healthEntries => 'Entrees';

  @override
  String get healthNoEntries => 'Aucune entree pour le moment';

  @override
  String healthFirstEntry(String name) {
    return 'Consignez votre premiere mesure de $name.';
  }

  @override
  String get workoutReportLoadFailed => 'Impossible de charger le rapport d\'entrainement.';

  @override
  String get workoutReportTitle => 'Rapport d\'entrainement';

  @override
  String get workoutReportAdditionalDetails => 'Détails supplémentaires';

  @override
  String get recommendedSetsEdit => 'Modifier les séries recommandées';

  @override
  String get recommendedSetsTitle => 'Séries recommandées';

  @override
  String get recommendedSetsMinimum => 'Minimum de séries recommandées';

  @override
  String get recommendedSetsMaximum => 'Maximum de séries recommandées';

  @override
  String get recommendedSetsValidNumbers => 'Entrez des nombres de séries valides.';

  @override
  String get recommendedSetsNonNegative => 'Le nombre de séries ne peut pas être négatif.';

  @override
  String get recommendedSetsRange => 'Le maximum doit être au moins égal au minimum.';

  @override
  String get workoutReportWorkouts => 'Seances';

  @override
  String get workoutReportTime => 'Temps';

  @override
  String get workoutReportVolume => 'Volume';

  @override
  String get workoutReportWorkout => 'seance';

  @override
  String get workoutReportTotal => 'au total';

  @override
  String get databaseSettingsTitle => 'Reglages de la base de donnees';

  @override
  String get databaseSettingsSubtitle => 'Sauvegardes, medias infonuagiques, verifications de sante et exports de developpement.';

  @override
  String get databaseBackupRestore => 'Sauvegarde et restauration';

  @override
  String get databaseBackupRestoreSubtitle => 'Importez ou exportez vos donnees Tonos locales de facon securitaire.';

  @override
  String get databaseExportBackup => 'Exporter la sauvegarde de la base de donnees';

  @override
  String get databaseImportBackup => 'Importer une sauvegarde de base de donnees';

  @override
  String get databaseImportBackupSubtitle => 'Remplace les donnees locales a partir d\'un fichier exporte enregistre.';

  @override
  String get databaseHealth => 'Sante';

  @override
  String get databaseHealthSubtitle => 'Un apercu de la taille de la base, du schema et de l\'index de recherche.';

  @override
  String get databaseCheckingHealth => 'Verification de la sante de la base...';

  @override
  String get databaseCheckingHealthSubtitle => 'Lecture du schema, de la taille, des tables et des index.';

  @override
  String get databaseHealthFailed => 'Echec de la verification de la base de donnees';

  @override
  String get databaseMaintenance => 'Entretien';

  @override
  String get databaseMaintenanceSubtitle => 'Outils securitaires de verification, d\'optimisation et de nettoyage du stockage.';

  @override
  String get databaseRefreshHealth => 'Actualiser la sante';

  @override
  String get databaseIntegrityCheck => 'Executer la verification d\'integrite';

  @override
  String get databaseIntegrityCheckSubtitle => 'Demander a SQLite de verifier le fichier de base de donnees local.';

  @override
  String get databaseOptimize => 'Optimiser la base de donnees';

  @override
  String get databaseCheckpointWal => 'Point de controle WAL';

  @override
  String get databaseCheckpointWalSubtitle => 'Ecrit le journal anticipe dans le fichier de base de donnees.';

  @override
  String get databaseVacuum => 'Compacter la base de donnees';

  @override
  String get databaseVacuumSubtitle => 'Recupere l\'espace libre apres des suppressions ou importations importantes.';

  @override
  String get databaseCloudContent => 'Contenu infonuagique';

  @override
  String get databaseCloudContentSubtitle => 'Gerez le stockage des medias d\'exercices, d\'equipement et d\'anatomie.';

  @override
  String get databaseWifiOnly => 'Telechargements en Wi-Fi seulement';

  @override
  String get databaseWifiOnlySubtitle => 'Les nouvelles miniatures et videos se telechargent uniquement en Wi-Fi. Les medias en cache restent accessibles hors ligne.';

  @override
  String get databaseSyncExerciseMedia => 'Synchroniser les medias d\'exercices distants';

  @override
  String get databaseSyncSharedMedia => 'Synchroniser les medias du catalogue partage';

  @override
  String get databaseSyncSharedMediaSubtitle => 'Illustrations d\'equipement, de parties du corps et de muscles.';

  @override
  String get databaseClearMediaCache => 'Vider le cache des medias telecharges';

  @override
  String get databaseClearMediaCacheSubtitle => 'Retire de cet appareil les fichiers medias distants mis en cache.';

  @override
  String get databaseDefinitionExports => 'Exports de definitions';

  @override
  String get databaseDefinitionExportsSubtitle => 'Exportez les fichiers de definition de l\'application pour inspection ou outils.';

  @override
  String get exerciseEditorTitle => 'Editeur d\'exercices';

  @override
  String get exerciseEditorLoadFailed => 'Impossible de charger les definitions d\'exercices.';

  @override
  String get exerciseEditorChoose => 'Choisir un exercice';

  @override
  String get exerciseEditorEdit => 'Modifier la definition';

  @override
  String get exerciseEditorCreate => 'Creer un exercice personnalise';

  @override
  String get exerciseEditorSaveChanges => 'Enregistrer les modifications';

  @override
  String get exerciseEditorSaving => 'Enregistrement';

  @override
  String get exerciseEditorMuscles => 'Muscles';

  @override
  String get exerciseEditorBodyparts => 'Parties du corps';

  @override
  String get exerciseEditorEquipment => 'Equipement';

  @override
  String get exerciseEditorGuide => 'Guide';

  @override
  String exerciseProgressAlreadyShown(String name) {
    return '$name est deja affiche.';
  }

  @override
  String get exerciseProgressTrendTitle => 'Tendance du 1RM';

  @override
  String get exerciseProgressTrendBody => 'Ce graphique compare le 1RM reel enregistre et le 1RM estime au fil du temps. Touchez les points pour les valeurs exactes.';

  @override
  String get exerciseProgressRecordings => 'Releves';

  @override
  String get exerciseProgressRecordingsBody => 'Chaque releve ouvre l\'entrainement ou ce mouvement a ete effectue afin que vous puissiez consulter le contexte complet.';

  @override
  String get exerciseProgressTitle => 'Progres du 1RM';

  @override
  String get exerciseProgressEmpty => 'Terminez cet exercice pour commencer a construire son historique de progres.';

  @override
  String get exerciseProgressActual => '1RM reel';

  @override
  String get exerciseProgressEstimated => '1RM estime';

  @override
  String get exerciseProgressSessionOpenFailed => 'Impossible d\'ouvrir la seance d\'entrainement.';

  @override
  String get exerciseProgressSessionMissing => 'Seance d\'entrainement introuvable.';

  @override
  String exerciseProgressEstimatedValue(String value) {
    return 'Est. $value';
  }

  @override
  String get exerciseProgressNoActual => 'Aucun 1RM reel';

  @override
  String exerciseProgressActualValue(String value) {
    return 'Reel $value';
  }

  @override
  String get musclePercentTitle => '% sollicite par muscle';

  @override
  String musclePercentLoadFailed(String error) {
    return 'Impossible de charger les entrees : $error';
  }

  @override
  String musclePercentUpdateFailed(String error) {
    return 'Impossible de mettre a jour le pourcentage : $error';
  }

  @override
  String musclePercentResetFailed(String error) {
    return 'Impossible de reinitialiser la valeur par defaut : $error';
  }

  @override
  String musclePercentError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get musclePercentNoExercises => 'Aucun exercice defini';

  @override
  String get musclePercentEmpty => 'Aucun pourcentage musculaire defini';

  @override
  String get musclePercentLabel => '%';

  @override
  String get musclePercentRevert => 'Revenir a la valeur par defaut';

  @override
  String get sevenDayFocusTitle => 'Apercu hebdomadaire';

  @override
  String get sevenDayFocusLoadFailed => 'Impossible de charger l\'activite des 7 derniers jours';

  @override
  String get sevenDayFocusEmpty => 'Aucune unite de serie terminee par partie du corps au cours des 7 derniers jours.';

  @override
  String get sevenDayFocusMore => 'plus';

  @override
  String get pastSessionsWeek => 'Semaine';

  @override
  String get pastSessionsMonth => 'Mois';

  @override
  String get pastSessionsYear => 'Annee';

  @override
  String get pastSessionsAll => 'Tout';

  @override
  String get pastSessionsShow => 'Afficher :';

  @override
  String get pastSessionsFullscreen => 'Plein ecran';

  @override
  String pastSessionsError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get pastSessionsEmpty => 'Aucune seance pour le moment.';

  @override
  String pastSessionsItem(String date, int minutes) {
    return '$date - $minutes min';
  }

  @override
  String get historySummaryLoadFailed => 'Erreur lors du chargement de l\'historique';

  @override
  String get historySummaryWorkouts => 'Seances';

  @override
  String get historySummaryTotalTime => 'Temps total';

  @override
  String get historySummaryTotalVolume => 'Volume total';

  @override
  String get planCoachSkipGuide => 'Passer le guide';

  @override
  String get planCoachContinue => 'Continuer';

  @override
  String get trainOptimizedSettingsTitle => 'Reglages de l\'entrainement optimise';

  @override
  String get trainOptimizedSettingsBudgetBody => 'Utilise 3 minutes par serie et 5 minutes pour commencer chaque exercice.';

  @override
  String get trainOptimizedSettingsFocusBody => 'Les choix de parties du corps s\'appliquent seulement au prochain entrainement optimise.';

  @override
  String get trainWorkoutDuration => 'Duree de l\'entrainement';

  @override
  String get trainMinutesShort => 'min';

  @override
  String get trainSetsPerExercise => 'Maximum de series par exercice';

  @override
  String get trainSetsShort => 'series';

  @override
  String get trainBodypartFocus => 'Cible de parties du corps';

  @override
  String get trainBodypartFocusHelp => 'Touchez une fois pour preferer une partie du corps, deux fois pour l\'eviter et trois fois pour effacer le choix.';

  @override
  String get trainBodypartsLoadFailed => 'Impossible de charger les parties du corps.';

  @override
  String get trainPlanGenerated => 'Plan genere. Ouverture en cours.';

  @override
  String trainPlansGenerated(int count) {
    return '$count plans generes.';
  }

  @override
  String get trainActiveWorkoutKept => 'Un autre entrainement est deja en cours; il est reste inchange.';

  @override
  String get trainMenuTitle => 'Menu entrainement';

  @override
  String get trainExerciseCatalog => 'Catalogue d\'exercices';

  @override
  String get trainMuscleFilter => 'Filtre musculaire';

  @override
  String get trainGymSettings => 'Reglages du gym et des entrainements';

  @override
  String get trainTab => 'Entrainement';

  @override
  String get trainHistoryTab => 'Historique';

  @override
  String get trainExercisePresets => 'Plans d\'exercices';

  @override
  String get trainGeneratePlans => 'Generer des plans personnalises';

  @override
  String get trainAddPlan => 'Ajouter un plan manuellement';

  @override
  String get trainNewPlanFirst => 'Nouveau plan';

  @override
  String trainNewPlan(int number) {
    return 'Nouveau plan $number';
  }

  @override
  String get trainBuildingOptimized => 'Creation de l\'entrainement optimise...';

  @override
  String get trainStartOptimized => 'Demarrer l\'entrainement optimise';

  @override
  String get trainNewSession => 'Nouvelle seance';

  @override
  String get foodCustomizationTitle => 'Personnaliser un aliment';

  @override
  String get foodCustomizationEditTitle => 'Modifier un aliment';

  @override
  String get foodCustomizationName => 'Nom de l\'aliment';

  @override
  String get foodCustomizationEnterName => 'Saisissez un nom';

  @override
  String get foodCustomizationBrand => 'Marque';

  @override
  String get foodCustomizationFoodPhoto => 'Photo de l\'aliment';

  @override
  String get foodCustomizationLabelPhoto => 'Photo de l\'etiquette';

  @override
  String get foodCustomizationDensity => 'Densite (g/mL)';

  @override
  String get foodCustomizationDensityHelp => 'Sert a convertir les portions en mL (tasses, c. a soupe) en grammes pour le calcul des macros.';

  @override
  String get foodCustomizationCalories => 'Calories (kcal)';

  @override
  String get foodCustomizationMacronutrients => 'Macronutriments';

  @override
  String get foodCustomizationMicronutrients => 'Micronutriments';

  @override
  String get foodCustomizationAdditionalComponents => 'Composants supplementaires';

  @override
  String get foodCustomizationPortionInfo => 'Information sur les portions';

  @override
  String get foodCustomizationBasisPortion => 'Base des valeurs nutritionnelles';

  @override
  String get foodCustomizationUsualPortion => 'Portion habituelle consommee';

  @override
  String get foodCustomizationAddPortion => 'Ajouter une portion';

  @override
  String get foodCustomizationUnit => 'Unite';

  @override
  String get foodCustomizationAmount => 'Quantite';

  @override
  String get foodCustomizationWeight => 'Poids (g)';

  @override
  String get foodCustomizationVolume => 'Volume (mL)';

  @override
  String get dashboardArchivedPlans => 'Plans archives';

  @override
  String get dashboardActivePlans => 'Plans actifs';

  @override
  String get dashboardManagePlans => 'Gerer les plans';

  @override
  String get dashboardSelectProfilePlans => 'Choisissez un profil d\'entrainement pour voir ses plans.';

  @override
  String get dashboardNoArchivedPlans => 'Aucun plan archive pour ce profil.';

  @override
  String get dashboardNoActivePlans => 'Aucun plan actif. Utilisez le crayon pour choisir des plans.';

  @override
  String dashboardPremadeCount(int count) {
    return '$count routines pretes a utiliser peuvent etre ajoutees.';
  }

  @override
  String get dashboardBrowsePremadePlans => 'Parcourir les plans predefinis';

  @override
  String get dashboardNewPlanFirst => 'Nouveau plan';

  @override
  String dashboardNewPlan(int number) {
    return 'Nouveau plan $number';
  }

  @override
  String get dashboardPlanTools => 'Outils de plan';

  @override
  String get dashboardPlanToolsBody => 'Creez un plan selon vos preferences d\'entrainement ou commencez-en un vide.';

  @override
  String get dashboardManual => 'Manuel';

  @override
  String get dashboardGenerate => 'Generer';

  @override
  String get dashboardMostUsedExercises => 'Exercices les plus pratiques';

  @override
  String get dashboardMostUsedExercisesEmpty => 'Terminez des entrainements pour voir ici vos exercices les plus frequents.';

  @override
  String premadeDiscardFailed(String error) {
    return 'Impossible d\'abandonner les plans ajoutes : $error';
  }

  @override
  String get premadeEquipmentSelectProfile => 'Choisissez un profil d\'entrainement pour adapter les plans a l\'equipement disponible.';

  @override
  String get premadeEquipmentExact => 'Les plans predefinis sont affiches tels quels.';

  @override
  String get premadeEquipmentChecking => 'Verification des exercices du plan avec votre profil...';

  @override
  String get premadeEquipmentMissing => 'Aucun equipement n\'a ete trouve pour le profil; les plans restent inchanges.';

  @override
  String premadeEquipmentReplacements(int count) {
    return '$count exercice(s) non disponible(s) seront remplace(s) a l\'ajout des plans.';
  }

  @override
  String get premadeEquipmentFits => 'Les plans conviennent deja a l\'equipement du profil actuel.';

  @override
  String get premadeOneHour => '1 h';

  @override
  String get premadeTwoHours => '2 h';

  @override
  String premadePlansAvailable(int count) {
    return '$count plan(s) disponible(s)';
  }

  @override
  String get premadeNoTemplates => 'Aucun modele de plan pour le moment';

  @override
  String premadePlansCount(int count) {
    return '$count plan(s)';
  }

  @override
  String get premadeTemplatesLater => 'Des modeles pour cette repartition pourront etre ajoutes ici plus tard.';

  @override
  String premadeExerciseCount(int count) {
    return '$count exercices';
  }

  @override
  String premadeSetCount(int count) {
    return '$count series';
  }

  @override
  String premadeSwappedCount(int count) {
    return '$count remplace(s)';
  }

  @override
  String get premadeAdding => 'Ajout...';

  @override
  String get premadeChecking => 'Verification...';

  @override
  String get premadeProfileSwap => 'remplacement du profil';

  @override
  String get healthEntryValueUnitRequired => 'Saisissez d\'abord une valeur et une unite.';

  @override
  String get healthDefinitionFieldsRequired => 'Saisissez un nom, une unite et une valeur valide.';

  @override
  String get healthUnit => 'Unite';

  @override
  String get healthNote => 'Note';

  @override
  String get healthOptional => 'Facultatif';

  @override
  String get healthMetricName => 'Nom de l\'indicateur';

  @override
  String get healthMetricNameHint => 'Tour de bras, frequence cardiaque au repos...';

  @override
  String healthUnitHint(String weightUnit) {
    return 'po, $weightUnit, %, bpm...';
  }

  @override
  String get healthStartingValue => 'Valeur initiale';

  @override
  String get healthCreate => 'Creer';

  @override
  String get exerciseProgressNoRecordings => 'Aucun enregistrement pour le moment';

  @override
  String get exerciseEditorDiscardTitle => 'Abandonner les modifications?';

  @override
  String get exerciseEditorDiscardBody => 'Vos modifications ne sont pas encore enregistrees. Vous pouvez continuer a modifier ou les abandonner.';

  @override
  String get exerciseEditorKeepEditing => 'Continuer la modification';

  @override
  String get exerciseEditorDiscard => 'Abandonner';

  @override
  String get exerciseEditorAddBodyparts => 'Ajouter des parties du corps associees';

  @override
  String get exerciseEditorAddMuscles => 'Ajouter des muscles associes';

  @override
  String get exerciseEditorAddEquipment => 'Ajouter de l\'equipement';

  @override
  String get databaseClearMediaTitle => 'Effacer les medias telecharges?';

  @override
  String get databaseClearMediaBody => 'Cette action retire les medias d\'exercices, d\'equipement et d\'anatomie en cache. L\'application pourra les telecharger de nouveau au besoin.';

  @override
  String get databaseClearCache => 'Effacer le cache';

  @override
  String get databaseCacheCleared => 'Le cache des medias telecharges a ete efface.';

  @override
  String databaseClearCacheFailed(String error) {
    return 'Impossible d\'effacer le cache : $error';
  }

  @override
  String get databaseContentEnvironment => 'Environnement de contenu';

  @override
  String get databaseLoadingEnvironment => 'Chargement de l\'environnement...';

  @override
  String get databaseChangeEnvironment => 'Changer d\'environnement';

  @override
  String get databaseExerciseManifestUrl => 'URL du manifeste des medias d\'exercices';

  @override
  String get databaseNoExerciseManifestUrl => 'Aucune URL de manifeste distant n\'est definie pour cet environnement.';

  @override
  String get databaseOverrideUrl => 'Remplacer l\'URL';

  @override
  String get databaseNoManifestSynced => 'Aucun manifeste synchronise';

  @override
  String databaseManifestVersion(int version) {
    return 'Manifeste v$version';
  }

  @override
  String databaseLastChecked(String date) {
    return 'Derniere verification : $date';
  }

  @override
  String get databaseSharedCatalogMedia => 'Medias partages du catalogue';

  @override
  String get databaseSharedMediaNotSynced => 'Pas encore synchronise. Equipement, parties du corps et muscles.';

  @override
  String databaseManifestLastChecked(int version, String date) {
    return 'Manifeste v$version. Derniere verification : $date';
  }

  @override
  String get databaseSharedManifestUrl => 'URL du manifeste des medias partages';

  @override
  String get databaseNoSharedManifestUrl => 'Aucune URL de medias partages distants n\'est definie pour cet environnement.';

  @override
  String get databaseDownloadedMediaCache => 'Cache des medias telecharges';

  @override
  String databaseCacheUsage(int count, String size) {
    return '$count fichiers, $size';
  }

  @override
  String get databaseLoadBundledManifest => 'Charger le manifeste integre';

  @override
  String get databaseTutorialFilesTitle => 'Fichiers de base de donnees';

  @override
  String get databaseTutorialFilesBody => 'Exportez une sauvegarde ou importez un fichier de base de donnees. Les imports exigent d\'abord une sauvegarde.';

  @override
  String get databaseTutorialHealthTitle => 'Sante de la base de donnees';

  @override
  String get databaseTutorialHealthBody => 'Cette carte indique la version du schema, la taille de la base, le nombre de tables et l\'etat de l\'index de recherche.';

  @override
  String get databaseTutorialMaintenanceTitle => 'Outils d\'entretien';

  @override
  String get databaseTutorialMaintenanceBody => 'Utilisez ces actions pour les verifications d\'integrite, l\'optimisation, le point de controle WAL ou le nettoyage lorsque necessaire.';

  @override
  String get databaseExportSavedTitle => 'Export de la base enregistre';

  @override
  String get databaseExportSavedBody => 'L\'export de la base de donnees a ete enregistre a l\'emplacement choisi.';

  @override
  String databaseImportBlocked(String message) {
    return 'Import bloque : $message';
  }

  @override
  String get databaseImportBackupCanceled => 'Import annule : la sauvegarde n\'a pas ete enregistree.';

  @override
  String get databaseImportSucceededTitle => 'Import reussi';

  @override
  String databaseImportSucceededBody(String name) {
    return '$name a ete importe. Une sauvegarde de la base locale precedente a d\'abord ete enregistree a l\'emplacement choisi.';
  }

  @override
  String get databaseConfirmImportTitle => 'Confirmer l\'import';

  @override
  String get databaseConfirmImportBody => 'Cette action remplace la base de donnees locale. Une sauvegarde de la base actuelle sera d\'abord creee.';

  @override
  String databaseImportFile(String name) {
    return 'Fichier : $name';
  }

  @override
  String databaseImportTables(int count) {
    return 'Tables : $count';
  }

  @override
  String databaseImportRows(int count) {
    return 'Lignes : $count';
  }

  @override
  String databaseImportSchema(int version) {
    return 'Schema exporte : v$version';
  }

  @override
  String get databaseImportLegacyFormat => 'Format : table de correspondance hereditee';

  @override
  String get databaseImportWarnings => 'Avertissements :';

  @override
  String get databaseBackupAndImport => 'Sauvegarder et importer';

  @override
  String databaseMaintenanceFailed(String error) {
    return 'Echec de l\'entretien de la base : $error';
  }

  @override
  String get exerciseEditorSaveBeforeAllocation => 'Enregistrez ou annulez les modifications avant de modifier le credit par serie.';

  @override
  String exerciseEditorRemoveItemTitle(String type) {
    return 'Retirer $type?';
  }

  @override
  String exerciseEditorRemoveItemBody(String name) {
    return 'Retirer \"$name\" de cette definition d\'exercice?';
  }

  @override
  String get exerciseEditorKeep => 'Garder';

  @override
  String get exerciseEditorMuscleOrderTitle => 'Ordre des muscles cibles';

  @override
  String get exerciseEditorMuscleOrderBody => 'Classez les muscles selon la force avec laquelle l\'exercice les cible. Cela aide Tonos a estimer le focus anatomique et a proposer de meilleurs exercices.';

  @override
  String get exerciseEditorExactSetCredit => 'Credit exact par serie';

  @override
  String get exerciseEditorExactSetCreditBody => 'Modifiez le credit precis qu\'une serie attribue a chaque muscle ou partie du corps dans Repartition des series par exercice.';

  @override
  String get exerciseEditorSetCreditScaling => 'Mise a l\'echelle du credit par serie';

  @override
  String get exerciseEditorSetCreditScalingBody => 'Choisissez si la note de cet exercice doit ajuster le credit par serie.';

  @override
  String get exerciseEditorScaleCreditByRating => 'Ajuster le credit selon la note';

  @override
  String get exerciseEditorScaleCreditByRatingBody => 'Applique la note de l\'exercice aux totaux analytiques des series.';

  @override
  String get exerciseEditorTargetMuscles => 'Muscles cibles';

  @override
  String get exerciseEditorOrderMusclesHint => 'Utilisez les fleches pour classer les muscles selon leur importance.';

  @override
  String exerciseEditorMusclesAssociated(int count) {
    return '$count muscles sont actuellement associes.';
  }

  @override
  String get exerciseEditorNoTargetMuscles => 'Aucun muscle cible n\'est encore associe.';

  @override
  String get exerciseEditorAddTargetMuscles => 'Ajouter des muscles cibles';

  @override
  String get exerciseEditorMoveUp => 'Monter';

  @override
  String get exerciseEditorMoveDown => 'Descendre';

  @override
  String get exerciseEditorRemoveMuscle => 'Retirer le muscle';

  @override
  String get exerciseEditorMuscleItem => 'le muscle';

  @override
  String get exerciseEditorAssociatedBodyparts => 'Parties du corps associees';

  @override
  String get exerciseEditorAssociatedBodypartsBody => 'Ces zones generales alimentent les cartes corporelles, la couverture hebdomadaire et les recommandations adaptees a l\'equipement.';

  @override
  String get exerciseEditorExactBodypartCredit => 'Credit exact par partie du corps';

  @override
  String get exerciseEditorExactBodypartCreditBody => 'Utilisez Repartition des series par exercice lorsqu\'une serie doit compter comme une quantite partielle precise pour une partie du corps.';

  @override
  String get exerciseEditorBodypartsHint => 'Ajoutez toutes les zones generales sollicitees par cet exercice.';

  @override
  String exerciseEditorBodypartsAssociated(int count) {
    return '$count parties du corps sont actuellement associees.';
  }

  @override
  String get exerciseEditorNoBodyparts => 'Aucune partie du corps n\'est encore associee.';

  @override
  String get exerciseEditorAutomaticPreview => 'Apercu automatique';

  @override
  String get exerciseEditorAutomaticPreviewBody => 'Focus actuel derive de la structure des muscles cibles.';

  @override
  String get exerciseEditorRemoveBodypart => 'Retirer la partie du corps';

  @override
  String get exerciseEditorBodypartItem => 'la partie du corps';

  @override
  String get exerciseEditorAvailableEquipment => 'Equipement disponible';

  @override
  String get exerciseEditorAvailableEquipmentBody => 'L\'equipement associe determine quels profils peuvent utiliser cet exercice et quels remplacements Tonos peut recommander.';

  @override
  String get exerciseEditorEquipmentHint => 'Ajoutez chaque element necessaire pour effectuer cet exercice.';

  @override
  String exerciseEditorEquipmentAssociated(int count) {
    return '$count elements sont associes.';
  }

  @override
  String get exerciseEditorNoEquipment => 'Aucun equipement n\'est encore associe.';

  @override
  String get exerciseEditorRemoveEquipment => 'Retirer l\'equipement';

  @override
  String get exerciseEditorEquipmentItem => 'l\'equipement';

  @override
  String get historySummaryAll => 'Tout';

  @override
  String historySummaryDuration(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String planCoachStepTitle(int step, int total, String title) {
    return '$step/$total - $title';
  }

  @override
  String get databaseManifestUrlRequired => 'Ajoutez d\'abord une URL de manifeste de medias d\'exercices valide.';

  @override
  String databaseContentSyncFailed(String error) {
    return 'Echec de la synchronisation du contenu : $error';
  }

  @override
  String databaseBundledContentSyncFailed(String error) {
    return 'Echec de la synchronisation du contenu integre : $error';
  }

  @override
  String get databaseSharedMediaUrlMissing => 'Cet environnement de contenu ne contient aucune URL de medias partages.';

  @override
  String databaseSharedContentSyncFailed(String error) {
    return 'Echec de la synchronisation du contenu partage : $error';
  }

  @override
  String databaseDefinitionExportFailed(String filename, String error) {
    return 'Echec de l\'export de $filename : $error';
  }

  @override
  String get databaseExerciseManifestDialogTitle => 'Manifeste des medias d\'exercices';

  @override
  String get databaseManifestUrl => 'URL du manifeste';

  @override
  String get databaseClear => 'Effacer';

  @override
  String get databaseNoManifestConfigured => 'Aucune URL de manifeste n\'est encore configuree.';

  @override
  String get databaseUseEnvironment => 'Utiliser l\'environnement';

  @override
  String get dashboardTargetAnatomy => 'Anatomie ciblee';

  @override
  String get dashboardBodyparts => 'Parties du corps';

  @override
  String get dashboardMuscles => 'Muscles';

  @override
  String get exerciseEditorCreateCustomTitle => 'Creer un exercice personnalise';

  @override
  String get exerciseEditorCreateCustomBody => 'Creez une definition personnalisee du catalogue, puis ajoutez son anatomie ciblee et ses conseils avant de l\'enregistrer.';

  @override
  String get exerciseEditorExerciseName => 'Nom de l\'exercice';

  @override
  String get exerciseEditorNoEquipmentChoice => 'Aucun equipement';

  @override
  String get exerciseEditorOpenedMessage => 'Exercice ouvert. Ajoutez son anatomie ciblee, puis enregistrez.';

  @override
  String exerciseEditorCreateFailed(String error) {
    return 'Impossible de creer l\'exercice personnalise. $error';
  }

  @override
  String get exerciseEditorWhatChangesTitle => 'Ce que cela modifie';

  @override
  String get exerciseEditorWhatChangesBody => 'Utilisez cet editeur avance pour modifier le nom d\'un exercice, son anatomie ciblee, son equipement, ses conseils de forme, sa note et ses medias de reference. Le credit exact par serie est gere separement pour rester coherent dans l\'application.';

  @override
  String get exerciseEditorChooseCatalog => 'Choisir un exercice du catalogue';

  @override
  String get exerciseEditorRating => 'Note';

  @override
  String get databaseNever => 'Jamais';

  @override
  String databaseExportDefinition(String filename) {
    return 'Exporter $filename';
  }

  @override
  String get exerciseEditorAddMedia => 'Ajouter un média';

  @override
  String get exerciseEditorEditMedia => 'Modifier le média';

  @override
  String get exerciseEditorMediaImage => 'Image';

  @override
  String get exerciseEditorMediaVideo => 'Vidéo';

  @override
  String get exerciseEditorMediaLink => 'Lien';

  @override
  String get exerciseEditorMediaType => 'Type';

  @override
  String get exerciseEditorMediaTitle => 'Titre';

  @override
  String get exerciseEditorMediaTitleHint => 'Libellé d\'affichage facultatif';

  @override
  String get exerciseEditorMediaRemoteUrl => 'URL distante';

  @override
  String get exerciseEditorMediaThumbnailUrl => 'URL de la vignette';

  @override
  String get exerciseEditorMediaThumbnailHint => 'URL facultative de l\'aperçu d\'image';

  @override
  String get exerciseEditorSelectBeforeMedia => 'Sélectionnez un exercice existant avant d\'y joindre un média.';

  @override
  String get exerciseEditorFormGuide => 'Guide d\'exécution';

  @override
  String get exerciseEditorFormGuideBody => 'Ces notes apparaissent dans la fiche de l\'exercice pour aider à l\'installer, l\'exécuter et comprendre le mouvement en toute sécurité.';

  @override
  String get exerciseEditorGuidance => 'Conseils';

  @override
  String get exerciseEditorGuidanceEditing => 'Rédigez des repères clairs et pratiques. Les modifications sont préparées jusqu\'à l\'enregistrement.';

  @override
  String get exerciseEditorGuidanceReadOnly => 'Les consignes et repères actuels de l\'exercice.';

  @override
  String get exerciseEditorSetUp => 'Installation';

  @override
  String get exerciseEditorSetUpHint => 'Position de départ, installation de l\'équipement et notes de sécurité.';

  @override
  String get exerciseEditorHowToPerform => 'Exécution';

  @override
  String get exerciseEditorHowToPerformHint => 'Les étapes essentielles du mouvement et son amplitude.';

  @override
  String get exerciseEditorCoachingTips => 'Conseils d\'entraînement';

  @override
  String get exerciseEditorCoachingTipsHint => 'Repères utiles, erreurs courantes et variantes.';

  @override
  String get exerciseEditorReferenceMedia => 'Médias de référence';

  @override
  String get exerciseEditorReferenceMediaBody => 'Utilisez des liens médias pour vos documents de référence privés. Les médias du catalogue géré peuvent être actualisés par la synchronisation de contenu.';

  @override
  String get exerciseEditorMediaLinks => 'Liens médias';

  @override
  String get exerciseEditorMediaLinksEditing => 'Ajoutez ou mettez à jour une image distante, une vidéo ou un lien de référence.';

  @override
  String exerciseEditorMediaLinksCount(int count) {
    return '$count média(s) actuellement lié(s).';
  }

  @override
  String get exerciseEditorNoReferenceMedia => 'Aucun média de référence n\'est encore lié.';

  @override
  String get exerciseEditorAddMediaLink => 'Ajouter un lien média';

  @override
  String get exerciseEditorRemoveMedia => 'Retirer le média';

  @override
  String get exerciseEditorMediaLinkItem => 'lien média';

  @override
  String exerciseEditorMediaReference(String type) {
    return 'Référence $type';
  }

  @override
  String get bengaliBangladeshLanguage => 'Bengali (Bangladesh)';

  @override
  String get simplifiedChineseLanguage => 'Chinois simplifié';

  @override
  String get hindiLanguage => 'Hindi';

  @override
  String get spanishLanguage => 'Espagnol';

  @override
  String get onboardingWeightHistoryTitle => 'Historique du poids';

  @override
  String get onboardingWeightHistorySubtitle => 'Quelques détails permettent d’estimer les objectifs nutritionnels plus judicieusement.';

  @override
  String get onboardingPreviouslyHeavier => 'Avez-vous déjà pesé au moins 10 lb de plus que votre poids actuel?';

  @override
  String get onboardingWeightTrendTitle => 'Tendance actuelle du poids';

  @override
  String get onboardingWeightTrendGaining => 'Prise de poids';

  @override
  String get onboardingWeightTrendLosing => 'Perte de poids';

  @override
  String get onboardingWeightTrendMaintaining => 'Maintien du poids';

  @override
  String get onboardingNotSure => 'Je ne sais pas';

  @override
  String get onboardingBodyFatEstimateTitle => 'Estimation du taux de graisse';

  @override
  String get onboardingBodyFatEstimateSubtitle => 'Choisissez l’estimation visuelle la plus proche. Une grande précision n’est pas nécessaire.';

  @override
  String get onboardingNutritionPreferencesTitle => 'Préférences nutritionnelles';

  @override
  String get onboardingNutritionPreferencesSubtitle => 'Ces préférences orientent les suggestions nutritionnelles après la configuration.';

  @override
  String get onboardingPreferredDiet => 'Régime préféré';

  @override
  String get onboardingDietBalanced => 'Équilibré';

  @override
  String get onboardingDietLowFat => 'Faible en gras';

  @override
  String get onboardingDietLowCarb => 'Faible en glucides';

  @override
  String get onboardingDietKeto => 'Cétogène';

  @override
  String get onboardingCalorieFloor => 'Minimum calorique';

  @override
  String get onboardingCalorieFloorHint => 'Minimum quotidien en kcal';

  @override
  String get onboardingTrainingDuringProgram => 'Entraînement pendant le programme';

  @override
  String get onboardingTrainingNone => 'Aucun';

  @override
  String get onboardingTrainingLifting => 'Musculation';

  @override
  String get onboardingTrainingCardio => 'Cardio';

  @override
  String get onboardingTrainingLiftingAndCardio => 'Musculation et cardio';

  @override
  String get onboardingProteinPreference => 'Apport en protéines préféré';

  @override
  String get onboardingProteinLow => 'Faible';

  @override
  String get onboardingProteinModerate => 'Modéré';

  @override
  String get onboardingProteinHigh => 'Élevé';

  @override
  String get onboardingProteinVeryHigh => 'Très élevé';

  @override
  String get onboardingGoalPaceTitle => 'Rythme de l’objectif';

  @override
  String get onboardingGoalPaceSubtitle => 'Prévisualisez un poids cible et un rythme hebdomadaire.';

  @override
  String get onboardingInitialDailyBudget => 'Budget quotidien initial';

  @override
  String get onboardingProjectedEndDate => 'Date de fin prévue';

  @override
  String get onboardingTargetWeight => 'Poids cible';

  @override
  String get onboardingTargetGoalRate => 'Rythme cible';

  @override
  String get onboardingPerWeek => 'Par semaine';

  @override
  String get onboardingPerMonth => 'Par mois';

  @override
  String get exerciseProgressTrackExercise => 'Suivre un exercice';

  @override
  String get exerciseProgressTrackExerciseBody => 'Choisissez un exercice pour suivre ici la tendance de son 1RM.';

  @override
  String get healthCustomMetric => 'Mesure personnalisée';

  @override
  String get healthLatest => 'Dernière';

  @override
  String get healthNoEntry => 'Aucune donnée';

  @override
  String get healthNotTrackedYet => 'Pas encore suivie';

  @override
  String get healthChange => 'Variation';

  @override
  String get healthNeedTwoEntries => '2 données requises';

  @override
  String get healthVersusPrevious => 'Par rapport à la précédente';

  @override
  String get healthRecords => 'Données';

  @override
  String get presetEstimatedTime => 'Durée estimée';

  @override
  String get presetNoFocusData => 'Aucune donnée de ciblage.';

  @override
  String get presetFocusPreviewHelp => 'Ajoutez des exercices de musculation avec des données anatomiques pour prévisualiser le ciblage du plan.';

  @override
  String get dashboardReorderHelp => 'Faites glisser les sections dans l’ordre qui vous convient.';

  @override
  String get exerciseEditorCachedLocally => 'En cache local';

  @override
  String databaseExerciseMediaSyncSuccess(int count, int version) {
    return '$count médias d’exercice synchronisés (v$version).';
  }

  @override
  String databaseBundledManifestLoaded(int version) {
    return 'Manifeste de médias d’exercice intégré chargé (v$version).';
  }

  @override
  String databaseSharedMediaSyncSuccess(int count, int version) {
    return '$count médias d’équipement et d’anatomie synchronisés (v$version).';
  }

  @override
  String get databaseHealthSchema => 'Schéma';

  @override
  String databaseHealthSchemaValue(int current, int target) {
    return 'v$current / cible v$target';
  }

  @override
  String get databaseHealthSize => 'Taille';

  @override
  String get databaseHealthJournal => 'Journal';

  @override
  String get databaseHealthTables => 'Tables';

  @override
  String databaseHealthTablesValue(int tables, int indexes, int triggers) {
    return '$tables tables, $indexes index, $triggers déclencheurs';
  }

  @override
  String get databaseHealthFoodSearch => 'Recherche d’aliments';

  @override
  String databaseHealthFoodSearchValue(int foods, int rows) {
    return '$foods aliments, $rows lignes FTS';
  }

  @override
  String get databaseHealthPath => 'Chemin';

  @override
  String get dashboardWorkoutInProgress => 'Entraînement en cours';

  @override
  String get dashboardNoSavedPlans => 'Aucun plan enregistré pour ce profil de salle.';

  @override
  String get exerciseProgressOneRepMax => 'Maximum sur 1 répétition';

  @override
  String get exerciseProgressEstimatedOneRepMax => '1RM estimé';

  @override
  String get onboardingPageWeight => 'Poids';

  @override
  String get onboardingPageBodyFat => 'Graisse corporelle';

  @override
  String get onboardingPageNutrition => 'Nutrition';

  @override
  String get onboardingPageGoal => 'Objectif';

  @override
  String dashboardRecordsThisWeek(int count, int total) {
    return '$count/$total cette semaine';
  }

  @override
  String dashboardRecordsAllTime(int count) {
    return '$count au total';
  }

  @override
  String get dashboardVisualBodyFat => 'Graisse corporelle visuelle';

  @override
  String get dashboardNewMetric => 'Nouvelle mesure';

  @override
  String get dashboardCurrentMetrics => 'Mesures actuelles';

  @override
  String get workoutReportDay => 'jour';

  @override
  String get workoutReportDays => 'jours';

  @override
  String get workoutReportWeek => 'semaine';

  @override
  String get workoutReportMonth => 'mois';

  @override
  String workoutReportAveragePer(String period) {
    return 'Moy. / $period';
  }

  @override
  String get workoutReportWorkoutsLowercase => 'entraînements';

  @override
  String get workoutReportLongestStreak => 'Plus longue série';

  @override
  String get workoutReportMostActive => 'Plus actif';

  @override
  String get workoutReportNoSessions => 'aucune séance';

  @override
  String get workoutReportWeekday => 'jour de la semaine';

  @override
  String workoutReportMetricSemantics(String label) {
    return 'Mesure de rapport : $label';
  }

  @override
  String workoutReportUnitLogged(String unit) {
    return '$unit enregistrées';
  }

  @override
  String workoutReportUnitOnDate(String unit, String date) {
    return '$unit le $date';
  }

  @override
  String get profileDiagnosticsTitle => 'Diagnostic et confidentialité';

  @override
  String get profileDiagnosticsSubtitle => 'Version, consentement aux rapports, historique de synchronisation et suppression des données.';

  @override
  String get diagnosticsTitle => 'Diagnostic et confidentialité';

  @override
  String get diagnosticsSubtitle => 'Comprenez et contrôlez les diagnostics de production.';

  @override
  String get diagnosticsAppSection => 'Informations sur l’application';

  @override
  String get diagnosticsAppSectionSubtitle => 'Utiles pour signaler un problème.';

  @override
  String get diagnosticsVersion => 'Version et build';

  @override
  String get diagnosticsLoading => 'Chargement...';

  @override
  String get diagnosticsUnavailable => 'Indisponible';

  @override
  String get diagnosticsCrashSection => 'Rapports de plantage';

  @override
  String get diagnosticsCrashSectionSubtitle => 'Rapports facultatifs et expurgés sur les défaillances inattendues.';

  @override
  String get diagnosticsCrashReporting => 'Partager les rapports de plantage';

  @override
  String get diagnosticsCrashUnavailable => 'Non configuré dans cette version. Aucun rapport ne peut être envoyé.';

  @override
  String get diagnosticsCrashEnabledBody => 'Activé avec votre consentement. Vous pouvez le désactiver à tout moment.';

  @override
  String get diagnosticsCrashDisabledBody => 'Désactivé par défaut. Activez-le seulement pour aider à diagnostiquer les plantages.';

  @override
  String get diagnosticsPrivacyPromiseTitle => 'Confidentialité intégrée';

  @override
  String get diagnosticsPrivacyPromiseBody => 'Les rapports contiennent la version de l’application, le contexte de la plateforme, un type d’erreur expurgé et la pile d’appels. Tonos exclut les noms, données de santé, contenus de base de données, captures d’écran, hiérarchie des vues, adresses réseau, traces de performance et analyses.';

  @override
  String get diagnosticsSyncSection => 'Historique de synchronisation';

  @override
  String get diagnosticsSyncSectionSubtitle => 'Les 30 derniers résultats des manifestes multimédias restent uniquement sur cet appareil.';

  @override
  String get diagnosticsNoSyncEvents => 'Aucun diagnostic de synchronisation';

  @override
  String get diagnosticsNoSyncEventsBody => 'Les résultats apparaîtront ici sans URL ni données personnelles.';

  @override
  String get diagnosticsClearHistory => 'Effacer l’historique';

  @override
  String get diagnosticsClearHistoryBody => 'Supprimer tous les diagnostics de synchronisation locaux.';

  @override
  String get diagnosticsHistoryCleared => 'Historique des diagnostics effacé.';

  @override
  String get diagnosticsExerciseMedia => 'Médias d’exercices';

  @override
  String get diagnosticsSharedMedia => 'Médias partagés';

  @override
  String get diagnosticsRemoteSource => 'Distant';

  @override
  String get diagnosticsBundledSource => 'Intégré';

  @override
  String get diagnosticsSyncSucceeded => 'Réussi';

  @override
  String get diagnosticsSyncFailed => 'Échec';

  @override
  String diagnosticsSyncEventTitle(String operation, String outcome) {
    return '$operation : $outcome';
  }

  @override
  String diagnosticsSyncEventDetails(String source, String timestamp, int duration, String version, String items) {
    return '$source • $timestamp • $duration ms • manifeste $version • $items éléments';
  }

  @override
  String get diagnosticsPrivacySection => 'Vos données';

  @override
  String get diagnosticsPrivacySectionSubtitle => 'Stockage local, conservation et suppression.';

  @override
  String get diagnosticsLocalDataTitle => 'Les données de forme restent locales';

  @override
  String get diagnosticsLocalDataBody => 'Les entraînements, données nutritionnelles, mesures corporelles et profils restent dans la base de données de cet appareil, sauf si vous exportez vous-même une sauvegarde.';

  @override
  String get diagnosticsDeletionTitle => 'Supprimer les diagnostics et les données';

  @override
  String get diagnosticsDeletionBody => 'Effacez l’historique ci-dessus et désactivez les rapports. Effacez le stockage de Tonos dans les réglages de l’appareil ou désinstallez l’application pour supprimer la base locale et les caches. Pour supprimer un rapport déjà envoyé, contactez le développeur avec les détails de l’événement dont vous disposez.';
}

/// The translations for French, as used in Canada (`fr_CA`).
class AppLocalizationsFrCa extends AppLocalizationsFr {
  AppLocalizationsFrCa(): super('fr_CA');

  @override
  String onboardingBodyWeightPerWeek(String percent) {
    return '$percent % du poids corporel/sem.';
  }

  @override
  String get dashboardExerciseFallback => 'Exercice';

  @override
  String dashboardExerciseUsage(String equipment, int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '1 fois',
    );
    return '$equipment - $_temp0';
  }

  @override
  String weightCardSetsDone(int completed, int total) {
    return '$completed/$total terminées';
  }

  @override
  String bodyHeatmapSemantics(String bodyPart) {
    return 'Carte thermique du corps pour $bodyPart';
  }

  @override
  String databaseSaveFile(String filename) {
    return 'Enregistrer $filename';
  }

  @override
  String databaseFileSaved(String filename) {
    return '$filename a été enregistré à l’emplacement sélectionné.';
  }

  @override
  String databaseProductionEnvironment(String label) {
    return '$label (production)';
  }

  @override
  String dashboardDaysAgo(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'il y a $count jours',
      one: 'il y a 1 jour',
    );
    return '$_temp0';
  }

  @override
  String get workoutReportRangeOneWeekShort => '1 sem.';

  @override
  String get workoutReportRangeOneMonthShort => '1 mois';

  @override
  String get workoutReportRangeThreeMonthsShort => '3 mois';

  @override
  String get workoutReportRangeSixMonthsShort => '6 mois';

  @override
  String get workoutReportRangeOneYearShort => '1 an';

  @override
  String get workoutReportRangeAll => 'Tout';

  @override
  String get workoutReportRangeOneWeek => '1 semaine';

  @override
  String get workoutReportRangeOneMonth => '1 mois';

  @override
  String get workoutReportRangeThreeMonths => '3 mois';

  @override
  String get workoutReportRangeSixMonths => '6 mois';

  @override
  String get workoutReportRangeOneYear => '1 an';

  @override
  String workoutReportChartTitle(String metric, String period) {
    return '$metric ($period)';
  }

  @override
  String workoutReportWorkoutCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count entraînements',
      one: '1 entraînement',
      zero: '0 entraînement',
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
      other: '$count heures',
      one: '1 heure',
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
  String get workoutReportNoWorkoutsYet => 'Aucun entraînement pour le moment';

  @override
  String get workoutReportNoTrainingTimeYet => 'Aucun temps d’entraînement pour le moment';

  @override
  String get workoutReportNoVolumeYet => 'Aucun volume enregistré pour le moment';

  @override
  String get workoutReportNoWorkoutsBody => 'Terminez un entraînement pour commencer à créer ce rapport.';

  @override
  String get workoutReportNoTrainingTimeBody => 'Les séances terminées ajouteront automatiquement des minutes ici.';

  @override
  String get workoutReportNoVolumeBody => 'Enregistrez les poids des séries terminées pour créer des tendances de volume.';

  @override
  String get appTitle => 'Tonos';

  @override
  String get uiAppearanceTitle => 'Interface et apparence';

  @override
  String get uiAppearanceSubtitle => 'Contrôlez l’apparence de Tonos et le comportement des onglets inférieurs.';

  @override
  String get displaySettingsTitle => 'Affichage';

  @override
  String get displaySettingsSubtitle => 'Préférences visuelles rapides.';

  @override
  String get darkModeTitle => 'Mode sombre';

  @override
  String get darkModeSubtitle => 'Utiliser le thème sombre de l\'application.';

  @override
  String get replayOnboardingTitle => 'Rejouer la configuration';

  @override
  String get replayOnboardingSubtitle => 'Activez cette option pour refaire la configuration. Elle se désactive une fois terminée.';

  @override
  String get weightUnitsTitle => 'Unités de poids';

  @override
  String weightUnitsSubtitle(String unit) {
    return 'Afficher les poids et le volume d\'entraînement en $unit.';
  }

  @override
  String get languageTitle => 'Langue';

  @override
  String get languageSubtitle => 'Choisissez la langue utilisée par Tonos.';

  @override
  String get systemDefaultLanguage => 'Langue du système';

  @override
  String get englishLanguage => 'English';

  @override
  String get canadianFrenchLanguage => 'Français (Canada)';

  @override
  String get navigationSettingsTitle => 'Navigation';

  @override
  String get navigationSettingsSubtitle => 'Choisissez les onglets affichés au bas de l\'écran et leur ordre.';

  @override
  String get editBottomTabsTitle => 'Modifier les onglets du bas';

  @override
  String get editBottomTabsSubtitle => 'Réorganisez les onglets actifs ou masquez ceux que vous n\'utilisez pas.';

  @override
  String get displaySettingsTutorialTitle => 'Paramètres d\'affichage';

  @override
  String get displaySettingsTutorialBody => 'Contrôlez le mode sombre, la langue, la reprise de la configuration, ainsi que les livres et les kilogrammes.';

  @override
  String get bottomTabsTutorialTitle => 'Onglets du bas';

  @override
  String get bottomTabsTutorialBody => 'Modifiez les onglets affichés et leur ordre.';

  @override
  String get onboardingPageWelcome => 'Bienvenue';

  @override
  String get onboardingPageBasics => 'Renseignements';

  @override
  String get onboardingPageFocus => 'Priorités';

  @override
  String get onboardingPageGymProfile => 'Profil de gym';

  @override
  String get onboardingPageEquipment => 'Équipement';

  @override
  String get onboardingPageWorkoutPlan => 'Plan d\'entraînement';

  @override
  String get onboardingPagePlanOverview => 'Aperçu des plans';

  @override
  String get onboardingPageSummary => 'Résumé';

  @override
  String get onboardingPreviousStepTooltip => 'Étape précédente';

  @override
  String onboardingStepProgress(int current, int total) {
    return 'Étape $current sur $total';
  }

  @override
  String get onboardingFinish => 'Terminer';

  @override
  String get onboardingSkip => 'Passer';

  @override
  String get onboardingFinishing => 'Finalisation...';

  @override
  String get onboardingFinishSetup => 'Terminer la configuration';

  @override
  String get onboardingNext => 'Suivant';

  @override
  String get onboardingSkipSetupTitle => 'Passer la configuration?';

  @override
  String get onboardingSkipSetupBody => 'Vous pouvez accéder à l\'accueil maintenant et terminer la configuration plus tard. Vous pourrez aussi rouvrir la configuration dans les paramètres.';

  @override
  String get onboardingCancel => 'Annuler';

  @override
  String get onboardingConfirm => 'OK';

  @override
  String onboardingFinishError(String error) {
    return 'Impossible de terminer la configuration : $error';
  }

  @override
  String get onboardingWelcomeTitle => 'Bienvenue dans Tonos';

  @override
  String get onboardingWelcomeSubtitle => 'Une courte configuration aide à personnaliser vos entraînements, le suivi nutritionnel et vos progrès.';

  @override
  String get onboardingLanguageSelectionTitle => 'Choisissez votre langue';

  @override
  String get onboardingLanguageSelectionHelp => 'La configuration se met à jour immédiatement. Vous pourrez modifier ce choix plus tard dans les paramètres.';

  @override
  String get onboardingTrainFeatureTitle => 'Entraînez-vous avec contexte';

  @override
  String get onboardingTrainFeatureBody => 'Utilisez vos préférences et votre historique pour orienter les suggestions d\'entraînement.';

  @override
  String get onboardingNutritionFeatureTitle => 'Soutenir les objectifs nutritionnels';

  @override
  String get onboardingNutritionFeatureBody => 'Choisissez le niveau d\'accompagnement nutritionnel voulu dans l\'application.';

  @override
  String get onboardingProgressFeatureTitle => 'Suivre vos progrès';

  @override
  String get onboardingProgressFeatureBody => 'Gardez vos données d\'entraînement et de nutrition liées au fil du temps.';

  @override
  String get onboardingBasicsTitle => 'Parlez-nous de vous';

  @override
  String get onboardingBasicsSubtitle => 'Ces renseignements sont facultatifs, mais ils aideront les futurs calculs.';

  @override
  String get onboardingNameLabel => 'Nom';

  @override
  String get onboardingNameHint => 'Entrez votre nom';

  @override
  String get onboardingGenderLabel => 'Genre';

  @override
  String get onboardingGenderMale => 'Homme';

  @override
  String get onboardingGenderFemale => 'Femme';

  @override
  String get onboardingGenderOther => 'Autre';

  @override
  String get onboardingGenderPreferNotToSay => 'Je préfère ne pas répondre';

  @override
  String get onboardingDateOfBirthLabel => 'Date de naissance';

  @override
  String get onboardingSelectDate => 'Choisir une date';

  @override
  String get onboardingHeightLabel => 'Taille';

  @override
  String get onboardingHeightHint => 'p. ex. 5 pi 10 po ou 178 cm';

  @override
  String get onboardingWorkoutWeightUnits => 'Unités de poids d\'entraînement';

  @override
  String get onboardingCurrentWeightLabel => 'Poids actuel';

  @override
  String get onboardingWeightHintPounds => 'p. ex. 160';

  @override
  String get onboardingWeightHintKilograms => 'p. ex. 72';

  @override
  String get onboardingPounds => 'Livres';

  @override
  String get onboardingKilograms => 'Kilogrammes';

  @override
  String get onboardingFocusTitle => 'Que devrait personnaliser Tonos?';

  @override
  String get onboardingFocusSubtitle => 'Choisissez les éléments à configurer maintenant. Vous pourrez les modifier plus tard.';

  @override
  String get onboardingNutritionDataTitle => 'Données nutritionnelles';

  @override
  String get onboardingNutritionDataPausedBody => 'La configuration nutritionnelle est suspendue pendant la reconstruction de cette section.';

  @override
  String get onboardingLater => 'Plus tard';

  @override
  String get onboardingExerciseDataTitle => 'Données d\'exercice';

  @override
  String get onboardingExerciseDataBody => 'Configurez votre profil de gym et vos premiers plans d\'entraînement.';

  @override
  String get onboardingGymSpaceTitle => 'Où vous entraînez-vous?';

  @override
  String get onboardingGymSpaceSubtitle => 'Choisissez un lieu de départ. Son équipement orientera les suggestions d\'exercices et les entraînements générés.';

  @override
  String get onboardingEquipmentLoadError => 'Impossible de charger l\'équipement.';

  @override
  String get onboardingTryAgain => 'Réessayer';

  @override
  String get onboardingGymCustomTitle => 'Espace personnalisé';

  @override
  String get onboardingGymCustomSubtitle => 'Créez votre propre profil en choisissant chaque élément disponible.';

  @override
  String get onboardingGymCustomDefaultName => 'Espace personnalisé';

  @override
  String get onboardingGymSkipTitle => 'Passer cette étape';

  @override
  String get onboardingGymSkipSubtitle => 'Conservez le profil général et choisissez votre équipement plus tard.';

  @override
  String get onboardingGymGeneralName => 'Général';

  @override
  String get onboardingGymCommercialTitle => 'Gym commercial';

  @override
  String get onboardingGymCommercialSubtitle => 'Commencez avec toutes les options d\'équipement, puis retirez celles que votre gym n\'a pas.';

  @override
  String get onboardingGymCommercialDefaultName => 'Gym commercial';

  @override
  String get onboardingGymHomeTitle => 'Gym à domicile';

  @override
  String get onboardingGymHomeSubtitle => 'Une installation pratique avec poids libres, bandes, banc et équipement de poids corporel.';

  @override
  String get onboardingGymHomeDefaultName => 'Gym à domicile';

  @override
  String get onboardingGymCalisthenicsTitle => 'Calisthénie';

  @override
  String get onboardingGymCalisthenicsSubtitle => 'Équipement centré sur le poids corporel, y compris barres, anneaux, bandes et accessoires de base.';

  @override
  String get onboardingGymCalisthenicsDefaultName => 'Calisthénie';

  @override
  String get onboardingGymPowerliftingTitle => 'Powerlifting';

  @override
  String get onboardingGymPowerliftingSubtitle => 'Un espace axé sur la barre avec disques, cage à squat et banc.';

  @override
  String get onboardingGymPowerliftingDefaultName => 'Powerlifting';

  @override
  String get onboardingGymFreeWeightsTitle => 'Poids libres';

  @override
  String get onboardingGymFreeWeightsSubtitle => 'Haltères, kettlebells, disques, banc et mouvements au poids du corps.';

  @override
  String get onboardingGymFreeWeightsDefaultName => 'Poids libres';

  @override
  String get onboardingReviewWorkoutSpaceTitle => 'Vérifiez votre espace d\'entraînement';

  @override
  String get onboardingReviewWorkoutSpaceSubtitle => 'Renommez le profil ou ajustez son équipement avant que Tonos le crée.';

  @override
  String get onboardingProfileNameLabel => 'Nom du profil';

  @override
  String get onboardingIncludedEquipmentTitle => 'Équipement inclus';

  @override
  String get onboardingIncludedEquipmentBody => 'Seuls les exercices pris en charge par cet équipement seront suggérés lorsque ce profil est actif.';

  @override
  String get onboardingNoEquipmentSelected => 'Aucun équipement n\'est sélectionné pour le moment.';

  @override
  String get onboardingReset => 'Réinitialiser';

  @override
  String get onboardingEditProfile => 'Modifier le profil';

  @override
  String get onboardingEditWorkoutSpaceTitle => 'Modifier l\'espace d\'entraînement';

  @override
  String get onboardingSelectEquipmentError => 'Sélectionnez au moins une option d\'équipement.';

  @override
  String get onboardingWorkoutPlanTitle => 'Configurez votre plan d\'entraînement';

  @override
  String get onboardingWorkoutPlanSubtitle => 'Choisissez comment Tonos doit préparer vos premiers plans. Vous pourrez toujours ajouter, archiver ou modifier des plans plus tard.';

  @override
  String get onboardingManualPlanTitle => 'Créer vos propres plans manuellement';

  @override
  String get onboardingManualPlanSubtitle => 'Commencez avec un plan vide, puis ajoutez vous-même les exercices et les séries.';

  @override
  String get onboardingPremadePlanTitle => 'Utiliser des plans d\'exercices prédéfinis';

  @override
  String get onboardingPremadePlanSubtitle => 'Parcourez les plans intégrés corps entier, haut/bas, pousser-tirer-jambes et les divisions par groupe musculaire.';

  @override
  String get onboardingGeneratePlanTitle => 'Générer des plans d\'exercices';

  @override
  String get onboardingGeneratePlanSubtitle => 'Répondez à quelques questions et laissez Tonos créer un plan personnalisé pour votre profil.';

  @override
  String get onboardingSkipPlanTitle => 'Passer cette étape';

  @override
  String get onboardingSkipPlanSubtitle => 'Commencez sans plan. Vous pourrez les configurer plus tard depuis Entraînement.';

  @override
  String onboardingPlansAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans ont été ajoutés aux plans actifs.',
      one: '$count plan a été ajouté aux plans actifs.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingReviewPlansTitle => 'Vérifiez vos plans';

  @override
  String get onboardingReviewPlansSubtitle => 'Ces plans ont été ajoutés à vos plans actifs. Ouvrez un plan pour l\'examiner ou l\'ajuster avant de continuer.';

  @override
  String onboardingPlansReady(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans sont prêts dans les plans actifs.',
      one: '$count plan est prêt dans les plans actifs.',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanOverviewLoadError => 'Impossible de charger l\'aperçu des plans pour le moment.';

  @override
  String get onboardingNoAddedPlans => 'Aucun plan ajouté n\'a été trouvé. Retournez ajouter des plans ou passez cette étape.';

  @override
  String get onboardingReadyTitle => 'Prêt à commencer';

  @override
  String get onboardingReadySubtitle => 'Vérifiez votre configuration, puis terminez pour entrer dans Tonos.';

  @override
  String get onboardingSummaryName => 'Nom';

  @override
  String get onboardingSummaryGender => 'Genre';

  @override
  String get onboardingSummaryDateOfBirth => 'Date de naissance';

  @override
  String get onboardingSummaryHeight => 'Taille';

  @override
  String get onboardingSummaryWeight => 'Poids';

  @override
  String get onboardingSummaryWorkoutUnits => 'Unités d\'entraînement';

  @override
  String get onboardingSummaryIncluded => 'Inclus';

  @override
  String get onboardingSummaryGymProfile => 'Profil de gym';

  @override
  String get onboardingSummaryEquipment => 'Équipement';

  @override
  String get onboardingSummaryWorkoutPlans => 'Plans d\'entraînement';

  @override
  String get onboardingSummaryProfileSection => 'Profil';

  @override
  String get onboardingSummaryTrainingSection => 'Configuration de l\'entraînement';

  @override
  String get onboardingSummaryNutritionSection => 'Préférences nutritionnelles';

  @override
  String get onboardingSummaryDiet => 'Régime';

  @override
  String get onboardingSummaryProteinPreference => 'Préférence de protéines';

  @override
  String get onboardingIncludedNutrition => 'Configuration nutritionnelle';

  @override
  String get onboardingIncludedExercise => 'Configuration d\'exercice';

  @override
  String get onboardingIncludedBasicOnly => 'Profil de base seulement';

  @override
  String onboardingEquipmentSelected(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sélectionnés',
      one: '$count sélectionné',
    );
    return '$_temp0';
  }

  @override
  String onboardingPlanSummaryAdded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans ajoutés',
      one: '$count plan ajouté',
    );
    return '$_temp0';
  }

  @override
  String get onboardingPlanSummaryPremade => 'Prédéfini sélectionné';

  @override
  String get onboardingPlanSummaryGenerated => 'Génération sélectionnée';

  @override
  String get onboardingPlanSummarySkipped => 'Passé';

  @override
  String get onboardingPlanSummaryManual => 'Manuel sélectionné';

  @override
  String get onboardingPlanSummaryNotSelected => 'Non sélectionné';

  @override
  String get onboardingNewPlan => 'Nouveau plan';

  @override
  String onboardingNumberedNewPlan(int number) {
    return 'Nouveau plan $number';
  }

  @override
  String get tabTrain => 'Entraînement';

  @override
  String get tabTrainSecondary => 'Entraînement 2';

  @override
  String get tabCatalog => 'Catalogue';

  @override
  String get tabLogbook => 'Journal';

  @override
  String get tabProgress => 'Progrès';

  @override
  String get tabProfile => 'Profil';

  @override
  String get tabDashboard => 'Tableau de bord';

  @override
  String get tabNutrition => 'Nutrition';

  @override
  String get tabNutritionLog => 'Journal nutritionnel';

  @override
  String get tabCombinedHistory => 'Historique combiné';

  @override
  String get tabFormAndPosing => 'Forme et poses';

  @override
  String get profileTitle => 'Profil';

  @override
  String get profileSubtitle => 'Personnalisez Tonos, gérez vos valeurs d’entraînement et gardez vos données en bon état.';

  @override
  String get profileAccountSectionTitle => 'Compte';

  @override
  String get profileAccountSectionSubtitle => 'Votre identité et l’apparence générale de l’application.';

  @override
  String get profileUserInformationTitle => 'Renseignements personnels';

  @override
  String get profileUserInformationSubtitle => 'Nom, données corporelles et profil d’activité.';

  @override
  String get profileUiAppearanceTitle => 'Interface et apparence';

  @override
  String get profileUiAppearanceSubtitle => 'Thème, configuration initiale et onglets inférieurs.';

  @override
  String get profileGuidedTutorialsTitle => 'Tutoriels guidés';

  @override
  String get profileGuidedTutorialsSubtitle => 'Rejouez les guides et réinitialisez l’aide guidée.';

  @override
  String get profileTrainingSectionTitle => 'Entraînement';

  @override
  String get profileTrainingSectionSubtitle => 'Valeurs par défaut des exercices et contrôles liés aux progrès.';

  @override
  String get profileGymWorkoutSettingsTitle => 'Réglages de gym et d’entraînement';

  @override
  String get profileGymWorkoutSettingsSubtitle => 'Génération d’entraînements, classements, flux et logique d’équipement.';

  @override
  String get profileProgressSettingsTitle => 'Réglages des progrès';

  @override
  String get profileProgressSettingsSubtitle => 'Configuration des mesures et du suivi des tendances.';

  @override
  String get profileDataSectionTitle => 'Données';

  @override
  String get profileDataSectionSubtitle => 'Outils de base de données, exportations, importations et entretien.';

  @override
  String get profileDatabaseSettingsTitle => 'Réglages de la base de données';

  @override
  String get profileDatabaseSettingsSubtitle => 'Importation, exportation, vérifications et outils d’entretien.';

  @override
  String get profileNutritionSectionTitle => 'Nutrition';

  @override
  String get profileNutritionSectionSubtitle => 'Les réglages de nutrition sont suspendus pendant la reconstruction de cette section.';

  @override
  String get profileDietNutritionSettingsTitle => 'Réglages de l’alimentation et de la nutrition';

  @override
  String get profileDietNutritionSettingsSubtitle => 'Les objectifs et préférences nutritionnels reviendront plus tard.';

  @override
  String get profileLater => 'Plus tard';

  @override
  String get profileAccountTutorialTitle => 'Réglages du compte';

  @override
  String get profileAccountTutorialBody => 'Mettez à jour vos renseignements personnels, préférences d’affichage, unités de poids, configuration initiale, onglets inférieurs et tutoriels guidés ici.';

  @override
  String get profileTrainingTutorialTitle => 'Réglages d’entraînement';

  @override
  String get profileTrainingTutorialBody => 'Contrôlez les profils de salle, les règles de génération, les classements des parties du corps, les réglages de progrès et les autres valeurs d’entraînement.';

  @override
  String get profileDataTutorialTitle => 'Outils de données';

  @override
  String get profileDataTutorialBody => 'Les réglages de la base de données permettent d’exporter, importer, vérifier et entretenir vos données locales d’entraînement.';

  @override
  String catalogLoadError(String error) {
    return 'Impossible de charger le catalogue : $error';
  }

  @override
  String get catalogNoData => 'Aucune donnée de catalogue n\'est encore disponible.';

  @override
  String get catalogExerciseTitle => 'Catalogue d’exercices';

  @override
  String get catalogMostUsedExercises => 'Exercices les plus utilisés';

  @override
  String get catalogNoExerciseHistory => 'Terminez des entraînements pour voir ici vos exercices les plus fréquents.';

  @override
  String get catalogTargetAnatomyTitle => 'Anatomie ciblée';

  @override
  String get catalogBodyparts => 'Parties du corps';

  @override
  String get catalogMuscles => 'Muscles';

  @override
  String get catalogNoBodypartHistory => 'Aucun historique de partie du corps pour le moment.';

  @override
  String get catalogNoMuscleHistory => 'Aucun historique musculaire pour le moment.';

  @override
  String get catalogExerciseTutorialTitle => 'Catalogue d\'exercices';

  @override
  String get catalogExerciseTutorialBody => 'Vos exercices les plus utilisés s\'affichent d\'abord ici. Touchez la carte pour ouvrir le catalogue complet, chercher des mouvements et consulter les détails.';

  @override
  String get catalogAnatomyTutorialTitle => 'Anatomie ciblée';

  @override
  String get catalogAnatomyTutorialBody => 'Ce résumé présente vos parties du corps et vos muscles les plus entraînés. Touchez l\'un ou l\'autre pour ouvrir la bibliothèque anatomique et voir des listes ciblées.';

  @override
  String catalogTimesUsed(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count fois',
      one: '1 fois',
    );
    return '$_temp0';
  }

  @override
  String catalogSetUnits(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séries',
      one: '1 série',
    );
    return '$_temp0';
  }

  @override
  String get navEditorMinimumTabsError => 'Veuillez conserver au moins deux onglets actifs.';

  @override
  String get navEditorSavedMessage => 'Configuration de navigation enregistrée.';

  @override
  String get navEditorTitle => 'Personnaliser les onglets';

  @override
  String get navEditorSubtitle => 'Choisissez les zones principales affichées dans la barre de navigation inférieure.';

  @override
  String get navEditorSave => 'Enregistrer les onglets';

  @override
  String get navEditorActiveTitle => 'Onglets visibles';

  @override
  String get navEditorActiveSubtitle => 'Ces onglets s’affichent dans votre navigation inférieure.';

  @override
  String get navEditorInactiveTitle => 'Onglets masqués';

  @override
  String get navEditorInactiveSubtitle => 'Vous pouvez les afficher de nouveau en tout temps.';

  @override
  String get navEditorNoInactiveTabs => 'Aucun onglet masqué.';

  @override
  String get navEditorAlwaysShown => 'Toujours affiché';

  @override
  String get navEditorVisible => 'Visible';

  @override
  String get navEditorHidden => 'Masqué';

  @override
  String get trainTutorialSpacesTitle => 'Entraînement comporte deux espaces';

  @override
  String get trainTutorialSpacesBody => 'Aperçu garde vos commandes d\'entraînement prêtes à utiliser à portée de main. Plans vous permet de parcourir, générer et gérer vos plans enregistrés.';

  @override
  String get trainTutorialWeeklyTitle => 'Aperçu hebdomadaire';

  @override
  String get trainTutorialWeeklyBody => 'Cette section montre les parties du corps entraînées récemment. Touchez la liste des séries ciblées pour ouvrir le détail hebdomadaire.';

  @override
  String get trainTutorialActivePlansTitle => 'Plans actifs';

  @override
  String get trainTutorialActivePlansBody => 'Les plans actifs sont les routines à garder près de vous. Utilisez le crayon pour choisir les plans qui restent prêts dans l\'onglet Aperçu.';

  @override
  String get trainTutorialStartTitle => 'Commencer ou optimiser';

  @override
  String get trainTutorialStartBody => 'Commencer un entraînement lance une séance vide. Optimiser crée une séance selon votre historique, l\'équipement du profil, vos priorités et vos règles de récupération.';

  @override
  String get trainTutorialProfilesTitle => 'Profils de gym';

  @override
  String get trainTutorialProfilesBody => 'Changez de profil lorsque vous vous entraînez ailleurs afin que les entraînements générés et les remplacements n\'utilisent que l\'équipement disponible.';

  @override
  String get trainSelectProfileFirst => 'Sélectionnez d\'abord un profil de gym.';

  @override
  String trainGeneratedPlans(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans ont été générés.',
      one: '1 plan a été généré.',
    );
    return '$_temp0';
  }

  @override
  String trainNewPlanName(int number) {
    String _temp0 = intl.Intl.pluralLogic(
      number,
      locale: localeName,
      other: 'Nouveau plan $number',
      one: 'Nouveau plan',
    );
    return '$_temp0';
  }

  @override
  String trainOptimizedWorkoutName(String date, String time) {
    return 'Entraînement optimisé $date $time';
  }

  @override
  String get trainRestTitle => 'Prenez le temps de récupérer';

  @override
  String get trainRestBody => 'Votre entraînement récent atteint déjà plusieurs limites de parties du corps; un entraînement optimisé nuirait trop à votre récupération.';

  @override
  String get commonOkay => 'OK';

  @override
  String get trainNoEligibleExercises => 'Aucun exercice admissible n\'a été trouvé pour ce profil.';

  @override
  String get trainAnotherWorkoutActive => 'Un autre entraînement est déjà en cours; il a été conservé tel quel.';

  @override
  String trainOptimizedStartFailed(String error) {
    return 'Impossible de commencer l\'entraînement optimisé : $error';
  }

  @override
  String trainOptimizedManualWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'L\'entraînement optimisé a commencé. $count exercices nécessitent encore des poids manuels.',
      one: 'L\'entraînement optimisé a commencé. 1 exercice nécessite encore un poids manuel.',
    );
    return '$_temp0';
  }

  @override
  String trainOptimizedStarterWeights(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'L\'entraînement optimisé a commencé avec des poids de départ pour $count nouveaux exercices.',
      one: 'L\'entraînement optimisé a commencé avec un poids de départ pour 1 nouvel exercice.',
    );
    return '$_temp0';
  }

  @override
  String get trainGymProfilesTooltip => 'Profils de gym';

  @override
  String get trainOverviewTab => 'Aperçu';

  @override
  String get trainPlansTab => 'Plans';

  @override
  String get trainActivePlans => 'Plans actifs';

  @override
  String get trainEditActivePlans => 'Modifier les plans actifs';

  @override
  String get trainSelectProfileForPlans => 'Sélectionnez un profil de gym pour choisir les plans actifs.';

  @override
  String get trainChooseActivePlans => 'Touchez le crayon pour choisir les plans affichés ici.';

  @override
  String get trainSelectedPlansMissing => 'Les plans sélectionnés ne sont plus disponibles. Touchez le crayon pour les mettre à jour.';

  @override
  String get trainArchivedPlans => 'Plans archivés';

  @override
  String get trainNoActivePlans => 'Aucun plan actif pour le moment. Utilisez le crayon sur la carte Plans actifs de l\'aperçu pour choisir ce qui reste prêt.';

  @override
  String get trainNoArchivedPlans => 'Aucun plan archivé.';

  @override
  String get trainManagePlans => 'Gérer les plans';

  @override
  String get trainPremadePlans => 'Plans prédéfinis';

  @override
  String trainPremadeDescription(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count routines sélectionnées sont disponibles à copier dans vos plans.',
      one: '1 routine sélectionnée est disponible à copier dans vos plans.',
    );
    return '$_temp0';
  }

  @override
  String get trainBrowsePremadePlans => 'Parcourir les plans prédéfinis';

  @override
  String get trainGenerateCustomPlans => 'Générer des plans personnalisés';

  @override
  String get trainManuallyAddPlan => 'Ajouter un plan manuellement';

  @override
  String get trainStartWorkout => 'Commencer l\'entraînement';

  @override
  String get trainOptimize => 'Optimiser';

  @override
  String get trainOptimizedSettings => 'Réglages de l\'entraînement optimisé';

  @override
  String planManagementDefaultName(int id) {
    return 'Plan $id';
  }

  @override
  String get planManagementActiveTutorialTitle => 'Plans actifs';

  @override
  String get planManagementActiveTutorialBody => 'Ces plans restent visibles dans l’aperçu Entraînement. Archivez-en un pour le masquer sans le supprimer.';

  @override
  String get planManagementArchivedTutorialTitle => 'Plans archivés';

  @override
  String get planManagementArchivedTutorialBody => 'Les plans archivés restent enregistrés. Activez n’importe quel plan ici pour le remettre dans l’aperçu.';

  @override
  String planManagementUpdateFailed(String plan, String error) {
    return 'Impossible de mettre à jour $plan : $error';
  }

  @override
  String get planManagementTitle => 'Gérer les plans';

  @override
  String get planManagementLoadFailed => 'Impossible de charger les plans';

  @override
  String get commonTryAgain => 'Réessayer';

  @override
  String get planManagementIntro => 'Choisissez les plans prêts dans votre aperçu Entraînement. Les plans archivés restent enregistrés et peuvent être activés en tout temps.';

  @override
  String get planManagementActiveSubtitle => 'Affichés dans l\'aperçu Entraînement.';

  @override
  String get planManagementNoActive => 'Aucun plan actif pour le moment. Activez un plan ci-dessous pour l\'épingler à l\'aperçu.';

  @override
  String get planManagementArchive => 'Archiver';

  @override
  String get planManagementArchivedSubtitle => 'Plans enregistrés qui ne figurent pas dans l\'aperçu.';

  @override
  String get planManagementNoArchived => 'Aucun plan archivé.';

  @override
  String get planManagementActivate => 'Activer';

  @override
  String get planManagementAutomatic => 'Plan automatique';

  @override
  String get planManagementVisible => 'Visible dans l\'aperçu';

  @override
  String get planManagementHidden => 'Masqué de l\'aperçu';

  @override
  String get presetsNoPlans => 'Aucun plan pour le moment.';

  @override
  String get presetsNoProfile => 'Sélectionnez un profil de salle pour voir les plans.';

  @override
  String get presetsLoadError => 'Impossible de charger les plans.';

  @override
  String presetsShowMore(int count) {
    return 'Afficher plus';
  }

  @override
  String presetsShowMoreRemaining(int count, int remaining) {
    return 'Afficher $count de plus';
  }

  @override
  String planDefaultName(int number) {
    return 'Nouveau plan';
  }

  @override
  String get planArchive => 'Archiver';

  @override
  String get planActivate => 'Activer';

  @override
  String get commonDelete => 'Supprimer';

  @override
  String get commonRename => 'Renommer';

  @override
  String get planActivated => 'Plan activé.';

  @override
  String get planArchived => 'Plan archivé.';

  @override
  String get planDeleteTitle => 'Supprimer le plan';

  @override
  String get planDeleteConfirmation => 'Voulez-vous vraiment supprimer ce plan?';

  @override
  String get commonCancel => 'Annuler';

  @override
  String get planRenameTitle => 'Renommer le plan';

  @override
  String get planNameLabel => 'Nom du plan';

  @override
  String get optimizedTutorialBudgetTitle => 'Budget de séance';

  @override
  String get optimizedTutorialBudgetBody => 'Définissez la durée de l’entraînement optimisé et le nombre de séries que chaque exercice peut recevoir.';

  @override
  String get optimizedTutorialRepsTitle => 'Répétitions et poids';

  @override
  String get optimizedTutorialRepsBody => 'Ces choix contrôlent le modèle de séries, les répétitions cibles et le caractère prudent des poids générés.';

  @override
  String get optimizedTutorialFocusTitle => 'Priorité des parties du corps';

  @override
  String get optimizedTutorialFocusBody => 'Préférez ou évitez des parties du corps pour le prochain entraînement optimisé sans modifier vos classements enregistrés.';

  @override
  String get commonReset => 'Réinitialiser';

  @override
  String get optimizedTutorialResetBody => 'Réinitialiser ramène cette page aux valeurs par défaut de Tonos si la configuration actuelle ne convient plus.';

  @override
  String get optimizedTutorialActionsTitle => 'Enregistrer ou commencer';

  @override
  String get optimizedTutorialActionsBody => 'Commencer maintenant utilise une fois les valeurs affichées. Enregistrer conserve les réglages pour les futurs entraînements optimisés.';

  @override
  String optimizedValidationError(int maxSets) {
    return 'Entrez une durée, une cible de répétitions et une plage de séries valides entre 1 et $maxSets.';
  }

  @override
  String get optimizedBudgetDescription => 'Utilise un budget de 3 minutes par série, plus 5 minutes pour commencer chaque exercice.';

  @override
  String get optimizedWorkoutDuration => 'Durée de l’entraînement';

  @override
  String get unitMinutesShort => 'min';

  @override
  String get optimizedMinimumSets => 'Nombre minimal de séries par exercice';

  @override
  String get optimizedMaximumSets => 'Maximum de séries par exercice';

  @override
  String get unitSets => 'séries';

  @override
  String get optimizedRepsWeightsTitle => 'Répétitions et poids';

  @override
  String get optimizedRepsWeightsDescription => 'Utilise des estimations de force fondées sur l’historique lorsqu’elles sont disponibles. Facile et Moyen réduisent davantage les charges que Difficile. Les nouveaux exercices utilisent des estimations prudentes.';

  @override
  String get optimizedRepPattern => 'Modèle de répétitions';

  @override
  String get repModeMixed => 'Mixte';

  @override
  String get repModePyramid => 'Pyramidal';

  @override
  String get repModeConsistent => 'Constant';

  @override
  String get optimizedTargetReps => 'Répétitions cibles';

  @override
  String get unitReps => 'rép.';

  @override
  String get optimizedWeightIntensity => 'Intensité du poids';

  @override
  String get intensityEasy => 'Facile';

  @override
  String get intensityMedium => 'Moyenne';

  @override
  String get intensityHard => 'Difficile';

  @override
  String get optimizedBodypartFocusTitle => 'Priorité des parties du corps';

  @override
  String get optimizedBodypartFocusDescription => 'Ces choix s’appliquent seulement au prochain entraînement optimisé lancé. Touchez une fois pour préférer, deux fois pour éviter, puis encore une fois pour effacer.';

  @override
  String get optimizedBodypartsUnavailable => 'Impossible de charger les parties du corps.';

  @override
  String get commonStartNow => 'Commencer maintenant';

  @override
  String get commonSave => 'Enregistrer';

  @override
  String get generateTutorialIntroTitle => 'Créer des plans';

  @override
  String get generateTutorialIntroBody => 'Cette page peut créer un plan ou un ensemble hebdomadaire équilibré selon votre profil de salle et vos préférences d’entraînement.';

  @override
  String get generateWorkoutSetupTitle => 'Configuration de l’entraînement';

  @override
  String get generateTutorialSetupBody => 'Définissez la durée de séance, le nombre de plans à créer et le maximum de séries autorisées pour chaque exercice.';

  @override
  String get generateTrainingFocusTitle => 'Priorité d’entraînement';

  @override
  String get generateTutorialFocusBody => 'Préférez ou évitez des parties du corps ici. L’option d’historique de 7 jours influence la génération seulement si vous voulez tenir compte du travail récent.';

  @override
  String get generateRepsWeightsTitle => 'Répétitions et poids';

  @override
  String get generateTutorialRepsBody => 'Choisissez des modèles de séries pyramidal, mixte ou constant, les répétitions cibles et l’intensité du poids de départ.';

  @override
  String get generateSetAllocationTitle => 'Répartition des séries';

  @override
  String get generateTutorialAllocationBody => 'Choisissez si les séries sont réparties uniformément ou favorisent vos classements de parties du corps ou de muscles.';

  @override
  String get generateTutorialGenerateTitle => 'Générer';

  @override
  String get generateTutorialGenerateBody => 'Lorsque tout est prêt, générez le plan ou l’ensemble de plans. Les nouveaux plans peuvent être examinés et modifiés par la suite.';

  @override
  String get generateValidationError => 'Entrez une durée, un nombre de plans, une limite de séries et des valeurs de répétitions valides.';

  @override
  String get generateNoViablePlans => 'Aucun plan viable n’a pu être généré avec les réglages actuels.';

  @override
  String generateFailed(String error) {
    return 'Échec de la génération des plans : $error';
  }

  @override
  String generateDiscardFailed(String error) {
    return 'Impossible d’ignorer les plans générés : $error';
  }

  @override
  String get generateIntroTitle => 'Créez votre semaine de plans';

  @override
  String get generateIntroBody => 'Créez un plan ou un ensemble équilibré selon votre profil, vos priorités et vos limites.';

  @override
  String generatePlanCountPill(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans',
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
    return '$sets séries max.';
  }

  @override
  String generateSetupSummary(String plans, String minutes, String sets) {
    return '$plans plan(s), $minutes min, $sets séries max.';
  }

  @override
  String get generateSessionLength => 'Durée de séance';

  @override
  String get generateSessionLengthHelp => 'Estimation : 3 min/série + 5 min/exercice.';

  @override
  String get generatePlansToCreate => 'Plans à créer';

  @override
  String generatePlansToCreateHelp(int maxPlans) {
    return 'Correspond généralement aux jours d’entraînement par semaine. Maximum : $maxPlans.';
  }

  @override
  String get unitPlans => 'plans';

  @override
  String get generateMaxSetsPerExercise => 'Maximum de séries par exercice';

  @override
  String generateSetLimitHelp(int minSets, int maxSets) {
    return '$minSets à $maxSets séries autorisées.';
  }

  @override
  String generateFocusSummary(int preferred, int avoided, String history) {
    return '$preferred préférées, $avoided évitées, historique de 7 jours : $history';
  }

  @override
  String get generateHistoryUsing => 'utilisé';

  @override
  String get generateHistoryNotUsing => 'non utilisé';

  @override
  String get generateUseRecentTraining => 'Utiliser l’entraînement récent';

  @override
  String get generateUseRecentTrainingBody => 'Favorise les zones peu entraînées au cours des 7 derniers jours.';

  @override
  String get generateBodypartFocusInstruction => 'Touchez une fois pour préférer, deux fois pour éviter, trois fois pour effacer.';

  @override
  String generateRepsSummary(String mode, String reps, String intensity) {
    return '$mode, $reps répétitions, intensité $intensity';
  }

  @override
  String get generateMixedBody => 'Pyramidal pour 3 séries ou plus; constant pour un travail plus court.';

  @override
  String get generatePyramidBody => 'La série de pointe utilise le poids de travail généré.';

  @override
  String get generateConsistentBody => 'Même nombre de répétitions et poids suggéré à chaque série.';

  @override
  String get generateTargetRepsHelp => 'Répétitions de pointe pour Pyramidal; répétitions constantes sinon.';

  @override
  String get generateEasyBody => 'Recommandation la plus prudente fondée sur l’historique ou le poids de départ.';

  @override
  String get generateMediumBody => 'Recommandation de poids de travail équilibrée.';

  @override
  String get generateHardBody => 'Recommandation la plus lourde, toujours arrondie et tenant compte de l’effort.';

  @override
  String get generateRequirementBodyparts => 'Classements des parties du corps';

  @override
  String get generateRequirementMuscles => 'Classements des muscles';

  @override
  String get generateRequirementEven => 'Couverture uniforme';

  @override
  String get generateEvenCoverageTitle => 'Couverture uniforme des parties du corps';

  @override
  String get generateEvenCoverageBody => 'Répartissez largement le travail entre les parties du corps disponibles.';

  @override
  String get generateBodypartRankingsTitle => 'Utiliser les classements des parties du corps';

  @override
  String get generateBodypartRankingsBody => 'Donnez plus de travail planifié aux parties du corps mieux classées.';

  @override
  String get generateRankBodyparts => 'Classer les parties du corps';

  @override
  String get generateMuscleRankingsTitle => 'Utiliser les classements des muscles';

  @override
  String get generateMuscleRankingsBody => 'Répartissez le travail selon vos priorités musculaires classées.';

  @override
  String get generateRankMuscles => 'Classer les muscles';

  @override
  String get generateGenerating => 'Génération...';

  @override
  String generateButton(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Générer $count plans',
      one: 'Générer le plan',
    );
    return '$_temp0';
  }

  @override
  String generatePartialMessage(int generated, int requested) {
    return '$generated plans sur $requested ont été générés. Vos réglages actuels ont limité les autres.';
  }

  @override
  String generateSuccessMessage(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count plans ont été générés. Examinez-les lorsque vous serez prêt.',
      one: 'Le plan généré a été ajouté. Examinez-le lorsque vous serez prêt.',
    );
    return '$_temp0';
  }

  @override
  String generateMoreNames(int count) {
    return '$count autres';
  }

  @override
  String get generateStarterEstimatedBody => 'Des poids de départ ont été estimés pour les nouveaux exercices. Ajustez-les au besoin après votre première série.';

  @override
  String get generateStarterUnavailableBody => 'Certains exercices nécessitent encore des poids manuels, car aucune estimation de départ sûre n’est disponible.';

  @override
  String get generateStarterDialogTitle => 'Poids de départ ajoutés';

  @override
  String get generatePageTitle => 'Générer des plans';

  @override
  String get generateDiscarding => 'Annulation...';

  @override
  String get generateReviewPlans => 'Examiner les plans';

  @override
  String get sessionTutorialCardsTitle => 'Cartes d\'exercice';

  @override
  String get sessionTutorialCardsBody => 'Chaque carte représente un exercice. Ouvrez-la pour modifier les poids et les répétitions, puis cochez les séries à mesure que vous les terminez.';

  @override
  String get sessionTutorialAddTitle => 'Ajouter des exercices';

  @override
  String get sessionTutorialAddBody => 'Utilisez ce bouton pour ajouter un exercice du catalogue pendant l\'entraînement.';

  @override
  String get sessionTutorialFinishTitle => 'Terminer l\'entraînement';

  @override
  String get sessionTutorialFinishBody => 'Lorsque vous avez terminé, finalisez la séance afin que Tonos enregistre l\'entraînement et mette à jour votre historique, vos analyses et vos widgets de progrès.';

  @override
  String get sessionTimerTitle => 'Minuteur d\'entraînement';

  @override
  String get sessionTitle => 'Séance d’entraînement';

  @override
  String get sessionNoExercises => 'Aucun exercice ajouté.';

  @override
  String get sessionNeedCompletedSet => 'Terminez au moins une série avant de finir l\'entraînement.';

  @override
  String sessionSaveFailed(String error) {
    return 'Impossible d\'enregistrer l\'entraînement. Votre entraînement en cours reste disponible. $error';
  }

  @override
  String get sessionFinishWorkout => 'Terminer l\'entraînement';

  @override
  String get sessionResume => 'Reprendre';

  @override
  String get sessionExit => 'Quitter';

  @override
  String get sessionCompletedSaved => 'Le travail terminé a été enregistré dans le Journal.';

  @override
  String get sessionCancelled => 'Entraînement annulé.';

  @override
  String sessionEndFailed(String error) {
    return 'Impossible de terminer l\'entraînement : $error';
  }

  @override
  String get sessionCancelQuestion => 'Annuler l\'entraînement?';

  @override
  String get sessionCancelBody => 'Cette action supprime l\'entraînement en cours sans l\'ajouter à votre historique.';

  @override
  String get sessionKeepWorkout => 'Conserver l\'entraînement';

  @override
  String get sessionCancelWorkout => 'Annuler l\'entraînement';

  @override
  String get sessionEndQuestion => 'Terminer l\'entraînement?';

  @override
  String get sessionCancelDelete => 'Annuler et supprimer';

  @override
  String get sessionEndSave => 'Terminer et enregistrer l\'entraînement';

  @override
  String get sessionRememberChoice => 'Mémoriser ce choix';

  @override
  String get sessionRememberChoiceBody => 'Vous pourrez modifier ce choix plus tard dans les réglages de gym et d\'entraînement.';

  @override
  String get sessionCompleteLoadError => 'Impossible de charger le résumé de l’entraînement terminé.';

  @override
  String get sessionCompleteTitle => 'ENTRAÎNEMENT TERMINÉ';

  @override
  String get sessionMetricExercises => 'Exercices';

  @override
  String get sessionMetricSets => 'Séries';

  @override
  String get sessionMetricDuration => 'Durée';

  @override
  String get sessionMetricVolume => 'Volume';

  @override
  String get commonDone => 'Terminé';

  @override
  String get recordMonthly => 'Mensuel';

  @override
  String get recordAllTime => 'Tous les temps';

  @override
  String get recordFirst => 'Premier record';

  @override
  String recordRepBest(int reps) {
    return 'Meilleur à $reps rép.';
  }

  @override
  String get recordVolumeBest => 'Meilleur volume';

  @override
  String sessionEstimatedMax(String weight) {
    return 'RM estimé = $weight';
  }

  @override
  String durationMinutesCompact(int minutes) {
    return '$minutes min';
  }

  @override
  String durationHoursCompact(int hours) {
    return '$hours h';
  }

  @override
  String durationHoursMinutesCompact(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String get planUnsavedChangesTitle => 'Modifications non enregistrées';

  @override
  String get planDiscardChangesQuestion => 'Ignorer les modifications?';

  @override
  String get planDiscard => 'Ignorer';

  @override
  String get planTutorialEditTitle => 'Modifier votre plan';

  @override
  String get planTutorialEditBody => 'Passez en mode modification pour changer le nom, les exercices, les séries ou les réglages du plan.';

  @override
  String get planTutorialSummaryTitle => 'Résumé du plan';

  @override
  String get planTutorialSummaryBody => 'Cette zone présente les exercices et les séries prévus. Utilisez-la pour vérifier votre plan avant de commencer.';

  @override
  String get planTutorialExerciseCardsTitle => 'Cartes d’exercices';

  @override
  String get planTutorialExerciseCardsBody => 'Chaque carte contient les séries, les répétitions et les poids du plan. Ouvrez-la pour la modifier.';

  @override
  String get planTutorialStartOrSaveTitle => 'Commencer ou enregistrer';

  @override
  String get planTutorialStartOrSaveBody => 'Commencez une séance avec ce plan ou enregistrez vos modifications pour les utiliser plus tard.';

  @override
  String get planGuideNameTitle => 'Nommez votre plan';

  @override
  String get planGuideNameBody => 'Donnez un nom à votre plan pour le reconnaître facilement dans Entraînement.';

  @override
  String get commonContinue => 'Continuer';

  @override
  String get planGuideBrowseTitle => 'Parcourir les exercices';

  @override
  String get planGuideBrowseBody => 'Ouvrez le catalogue pour sélectionner le premier exercice de votre plan.';

  @override
  String get planGuideWeightTitle => 'Ajoutez un poids';

  @override
  String get planGuideWeightBody => 'Entrez un poids de départ que vous pourrez ajuster à mesure que vous vous entraînez.';

  @override
  String get planGuideWeightSet => 'Poids de la série';

  @override
  String get planGuideRepsTitle => 'Ajoutez des répétitions';

  @override
  String get planGuideRepsBody => 'Entrez le nombre de répétitions visé pour cette série.';

  @override
  String get planGuideRepsSet => 'Répétitions de la série';

  @override
  String get planGuideAddSetTitle => 'Ajoutez une autre série';

  @override
  String get planGuideAddSetBody => 'Ajoutez des séries pour créer votre entraînement. Vous pourrez les modifier ou les supprimer plus tard.';

  @override
  String get planGuideSaveTitle => 'Enregistrez votre plan';

  @override
  String get planGuideSaveBody => 'Enregistrez le plan pour qu’il soit prêt dans votre aperçu Entraînement.';

  @override
  String planSaveFailed(String error) {
    return 'Impossible d\'enregistrer le plan. La version précédente n\'a pas été modifiée. $error';
  }

  @override
  String get planOngoingWorkoutKept => 'Votre entraînement en cours a été conservé. Terminez-le ou annulez-le avant de commencer ce plan.';

  @override
  String get planDeleteBody => 'Voulez-vous vraiment supprimer ce plan? Cette action est irréversible.';

  @override
  String get planDeletePreset => 'Supprimer le plan';

  @override
  String get planDisableAutomatic => 'Désactiver le plan automatique';

  @override
  String get planMakeAutomatic => 'Rendre le plan automatique';

  @override
  String get planAutomaticSettings => 'Réglages automatiques';

  @override
  String get planProgression => 'Progression du plan';

  @override
  String get planNoExercises => 'Aucun exercice dans ce plan.';

  @override
  String get planSavePreset => 'Enregistrer le plan';

  @override
  String get planStartSession => 'Commencer la séance';

  @override
  String get commonName => 'Nom';

  @override
  String get commonBack => 'Retour';

  @override
  String get flowMethodWeight => 'Poids';

  @override
  String get flowMethodReps => 'Répétitions';

  @override
  String get flowMethodAddSet => 'Ajouter une série';

  @override
  String get flowMethodDeleteSet => 'Supprimer une série';

  @override
  String get flowAppDefaultTitle => 'Progression par défaut de l’application';

  @override
  String get flowProfileDefaultTitle => 'Progression par défaut de la salle';

  @override
  String get flowPlanSubtitle => 'Définissez comment ce plan progresse après chaque entraînement.';

  @override
  String get flowAppDefaultSubtitle => 'Définissez le flux de progression initial pour les nouveaux profils de salle.';

  @override
  String flowProfileDefaultSubtitle(String profileName) {
    return 'Définissez le flux de progression initial pour les nouveaux plans dans $profileName.';
  }

  @override
  String get flowThisGymProfile => 'ce profil de salle';

  @override
  String get flowManageMethods => 'Gérer les actions';

  @override
  String get flowAddNewMethod => 'Ajouter une action';

  @override
  String get flowNewMethod => 'Nouvelle action';

  @override
  String get flowFactor => 'Facteur';

  @override
  String get flowAmount => 'Valeur';

  @override
  String get flowExplicit => 'Explicite';

  @override
  String get flowCopyFromSet => 'Copier depuis la série';

  @override
  String get flowWeight => 'Poids';

  @override
  String get flowReps => 'Répétitions';

  @override
  String get flowSetIndex => 'Indice de série (-1 = dernière)';

  @override
  String get flowDeleteLastSetBody => 'Cette action supprimera la dernière série.';

  @override
  String get flowMethodNameRequired => 'Le nom de l’action ne peut pas être vide';

  @override
  String get flowManageActionsTooltip => 'Gérer les actions de progression';

  @override
  String get flowAddBranchTitle => 'Ajouter une branche';

  @override
  String get flowAddBranchSubtitle => 'Choisissez où la prochaine réussite ou le prochain échec mène.';

  @override
  String get flowBranchFrom => 'Créer une branche depuis';

  @override
  String get flowSuccess => 'Réussite';

  @override
  String get flowMiss => 'Échec';

  @override
  String get flowAttachActionTitle => 'Associer une action de progression';

  @override
  String get flowAttachActionSubtitle => 'Appliquez un ajustement de chaque type à un nœud du flux.';

  @override
  String get flowApplyActionTo => 'Appliquer l’action à';

  @override
  String get flowProgressionAction => 'Action de progression';

  @override
  String get flowAddAction => '+ Action';

  @override
  String get flowRemoveAction => '- Action';

  @override
  String get flowRemoveNode => '- Nœud';

  @override
  String get commonEdit => 'Modifier';

  @override
  String get rulesEditAppDefault => 'Modifier la règle par défaut de l’application';

  @override
  String get rulesEditProfileDefault => 'Modifier la règle par défaut du profil';

  @override
  String get rulesAddAppDefault => 'Ajouter une règle par défaut de l’application';

  @override
  String get rulesAddProfileDefault => 'Ajouter une règle par défaut du profil';

  @override
  String get rulesCopy => 'Copier';

  @override
  String get rulesCopyIndex => 'Indice de copie';

  @override
  String get rulesDeleteLastSetBody => 'Cette action supprimera la dernière série.';

  @override
  String get rulesNameRequired => 'Le nom de la règle ne peut pas être vide';

  @override
  String get rulesProfilesLowercase => 'profils';

  @override
  String get rulesPlansLowercase => 'plans';

  @override
  String rulesAddToExistingTitle(String destination) {
    return 'Ajouter aux $destination existants?';
  }

  @override
  String rulesAddToExistingBody(String name, int count, String destination) {
    return 'Rendre « $name » disponible dans $count $destination existants? Les règles existantes du même nom et tous les flux de progression enregistrés resteront inchangés.';
  }

  @override
  String get rulesNotNow => 'Pas maintenant';

  @override
  String rulesAddTo(String destination) {
    return 'Ajouter aux $destination';
  }

  @override
  String rulesNoExistingNeeded(String destination) {
    return 'Aucun $destination existant n’a besoin de cette règle.';
  }

  @override
  String rulesCopiedMessage(String name, int count, String destination) {
    return '« $name » a été ajoutée à $count $destination.';
  }

  @override
  String get rulesPropagationFailed => 'Impossible d’ajouter la règle aux éléments existants.';

  @override
  String get rulesOptionsTooltip => 'Options de règle';

  @override
  String get rulesPageTitle => 'Règles de progression d’entraînement';

  @override
  String get rulesPageSubtitle => 'Créez des règles réutilisables pour modifier le poids, les répétitions et les séries après les tentatives d’entraînement.';

  @override
  String get rulesHowDefaultsTitle => 'Fonctionnement des valeurs par défaut';

  @override
  String get rulesHowDefaultsBody => 'Les valeurs par défaut de l’application sont copiées dans les nouveaux profils de salle. Les valeurs par défaut du profil sont copiées dans les nouveaux plans; les modifications ultérieures ne réécrivent donc pas les plans existants.';

  @override
  String get rulesAppDefaultsTitle => 'Valeurs par défaut de l’application';

  @override
  String get rulesAppDefaultsSubtitle => 'Les règles de départ pour les nouveaux profils de salle.';

  @override
  String get rulesNoAppDefaults => 'Aucune règle à l’échelle de l’application n’a encore été créée.';

  @override
  String get rulesAddApp => 'Ajouter une règle d’application';

  @override
  String get rulesGymProfilesTitle => 'Profils de salle';

  @override
  String get rulesGymProfilesSubtitle => 'Chaque profil conserve ensemble ses valeurs par défaut et ses règles de plan.';

  @override
  String get rulesNoProfiles => 'Créez un profil de salle pour ajouter des règles de profil et de plan.';

  @override
  String rulesProfileSummary(int profileRules, int planRules) {
    return '$profileRules règles de profil · $planRules règles de plan';
  }

  @override
  String get rulesProfileDefaultsTitle => 'Valeurs par défaut du profil';

  @override
  String get rulesProfileDefaultsSubtitle => 'Règles de départ pour les nouveaux plans de ce profil.';

  @override
  String get rulesNoProfileDefaults => 'Ce profil n’a aucune règle par défaut.';

  @override
  String get rulesAddProfile => 'Ajouter une règle de profil';

  @override
  String get rulesPlansTitle => 'Plans';

  @override
  String get rulesNoPlans => 'Aucun plan n’appartient encore à ce profil de salle.';

  @override
  String get rulesPlanOnlySubtitle => 'Règles utilisées uniquement par ce plan.';

  @override
  String get rulesNoPlanRules => 'Ce plan n’a aucune règle de progression spécifique.';

  @override
  String get rulesAddPlan => 'Ajouter une règle de plan';

  @override
  String get rulesAppDefaultsChip => 'Par défaut de l’application';

  @override
  String get rulesProfilesChip => 'Profils';

  @override
  String get rulesPlansChip => 'Plans';

  @override
  String get rulesEditPlan => 'Modifier la règle';

  @override
  String get rulesAddPlanTitle => 'Ajouter une règle';

  @override
  String get commonRetry => 'Réessayer';

  @override
  String get flowPageTitle => 'Flux de progression d’entraînement';

  @override
  String get flowPageSubtitle => 'Définissez les parcours qui déterminent comment les actions de progression s’appliquent après les résultats d’un entraînement.';

  @override
  String get flowHowCopiedTitle => 'Copie des flux';

  @override
  String get flowHowCopiedBody => 'Les flux de l’application deviennent le point de départ des nouveaux profils de salle. Les flux de salle deviennent le point de départ des nouveaux plans. Les modifications ultérieures restent limitées au flux ouvert ici.';

  @override
  String get flowLoadError => 'Impossible de charger les flux de progression d’entraînement.';

  @override
  String get flowAppDefaultsSubtitle => 'Le flux de départ pour les nouveaux profils de salle.';

  @override
  String get flowAppDefaultEntry => 'Flux par défaut de l’application';

  @override
  String get flowGymProfilesSubtitle => 'Chaque profil possède des valeurs par défaut et ses propres flux de plan.';

  @override
  String get flowNoProfiles => 'Créez un profil de salle pour définir les flux de profil et de plan.';

  @override
  String get flowNoSavedYet => 'Aucun flux enregistré';

  @override
  String flowSummary(int nodes, int branches, int actions) {
    return '$nodes nœuds | $branches branches | $actions actions';
  }

  @override
  String flowPlansAvailable(int count) {
    return '$count flux de plan disponibles';
  }

  @override
  String get flowGymDefaultEntry => 'Flux par défaut de la salle';

  @override
  String get gymSettingsTitle => 'Réglages de gym et d’entraînement';

  @override
  String get gymSettingsSubtitle => 'Ajustez la génération d’entraînements, les analyses et le comportement des flux.';

  @override
  String get gymSettingsLogicTitle => 'Logique d’entraînement';

  @override
  String get gymSettingsLogicSubtitle => 'Réglages qui influencent la planification et les entraînements générés.';

  @override
  String get gymSettingsWorkoutTitle => 'Réglages d’entraînement';

  @override
  String get gymSettingsWorkoutSubtitle => 'Limites de volume, valeurs par défaut d’analyse et contrôles d’entraînement.';

  @override
  String get gymSettingsExitTitle => 'Quitter un entraînement en cours';

  @override
  String get gymSettingsFlowToolsTitle => 'Outils de flux';

  @override
  String get gymSettingsFlowToolsSubtitle => 'Gérez les parcours et actions de progression enregistrés.';

  @override
  String get gymSettingsFlowsSubtitle => 'Modifiez les flux de progression pour l’application, les salles et les plans.';

  @override
  String get gymSettingsRulesSubtitle => 'Gérez les règles de progression du poids, des répétitions et des séries.';

  @override
  String get gymExitAsk => 'Demander à chaque fois';

  @override
  String get gymExitDiscard => 'Annuler et supprimer';

  @override
  String get gymExitSave => 'Terminer et enregistrer';

  @override
  String get gymExitAskBody => 'Affiche un choix lorsque vous quittez un entraînement en cours.';

  @override
  String get gymExitDiscardBody => 'Annule toujours l’entraînement en cours et ne l’enregistre pas dans l’historique.';

  @override
  String get gymExitSaveBody => 'Termine toujours l’entraînement et enregistre les séries terminées dans l’historique.';

  @override
  String get commonAll => 'Tout';

  @override
  String get catalogGuideChooseTitle => 'Choisir un exercice';

  @override
  String get catalogGuideChooseBody => 'Touchez une ligne d’exercice pour la sélectionner. La recherche ou les filtres peuvent vous aider à trouver le bon mouvement.';

  @override
  String get catalogGuideAddTitle => 'L’ajouter à votre plan';

  @override
  String catalogGuideAddBody(String exerciseName) {
    return 'Touchez + pour ajouter $exerciseName et revenir à votre plan.';
  }

  @override
  String get catalogGuideSearchTitle => 'Rechercher des exercices';

  @override
  String get catalogGuideSearchBody => 'Recherchez par nom d’exercice lorsque vous connaissez déjà le mouvement voulu.';

  @override
  String get catalogFilters => 'Filtres';

  @override
  String get catalogGuideFiltersBody => 'Filtrez par profil de salle, équipement, partie du corps ou muscle pour réduire rapidement le catalogue.';

  @override
  String get catalogGuideRowsTitle => 'Lignes d’exercices';

  @override
  String get catalogGuideRowsBody => 'Chaque ligne montre l’équipement et une carte thermique. Touchez la carte thermique pour les détails, ou sélectionnez la ligne lorsque vous choisissez un exercice.';

  @override
  String get catalogSelectedFilters => 'Filtres sélectionnés';

  @override
  String get catalogUseWorkspaceProfile => 'Utiliser le profil de l’espace';

  @override
  String get catalogWorkspaceProfile => 'Profil de l’espace';

  @override
  String get catalogEquipment => 'Équipement';

  @override
  String get catalogFocusArea => 'Zone ciblée';

  @override
  String get catalogSpecificMuscle => 'Muscle précis';

  @override
  String get catalogPageTitle => 'Catalogue d’exercices';

  @override
  String get catalogSearchExercises => 'Rechercher des exercices';

  @override
  String get catalogNoMatches => 'Aucun exercice ne correspond aux filtres.';

  @override
  String get catalogOpenExerciseInfo => 'Ouvrir les informations sur l’exercice';

  @override
  String get commonClose => 'Fermer';

  @override
  String get exerciseDetailOpenImage => 'Ouvrir l’image de l’exercice';

  @override
  String get exerciseDetailTutorialTitle => 'Détails de l’exercice';

  @override
  String get exerciseDetailTutorialBody => 'Le titre de la fiche correspond à l’exercice ouvert. Fermez-la ici lorsque vous avez terminé.';

  @override
  String get exerciseDetailTabsTutorialTitle => 'Détails, mesures, records';

  @override
  String get exerciseDetailTabsTutorialBody => 'Utilisez ces onglets pour passer des consignes aux meilleures levées et aux dossiers d’entraînement récents.';

  @override
  String get exerciseDetailContextTutorialTitle => 'Contexte de l’exercice';

  @override
  String get exerciseDetailContextTutorialBody => 'L’onglet Détails montre l’équipement, les parties du corps, les muscles et les notes de forme de l’exercice.';

  @override
  String get exerciseDetailSessionOpenFailed => 'Impossible d’ouvrir la séance d’entraînement.';

  @override
  String get exerciseDetailSessionNotFound => 'Séance d’entraînement introuvable.';

  @override
  String get exerciseDetailNoEquipment => 'Aucun équipement indiqué pour cet exercice.';

  @override
  String get exerciseDetailTargetAnatomy => 'Anatomie ciblée';

  @override
  String get exerciseDetailBodyParts => 'Parties du corps';

  @override
  String get exerciseDetailNoBodyParts => 'Aucune partie du corps indiquée.';

  @override
  String get exerciseDetailMuscles => 'Muscles';

  @override
  String get exerciseDetailNoMuscles => 'Aucun muscle indiqué.';

  @override
  String get exerciseDetailSetup => 'Mise en place';

  @override
  String get exerciseDetailNoSetup => 'Aucune instruction de mise en place fournie.';

  @override
  String get exerciseDetailExecution => 'Exécution';

  @override
  String get exerciseDetailNoExecution => 'Aucune note d’exécution fournie.';

  @override
  String get exerciseDetailTips => 'Conseils';

  @override
  String get exerciseDetailNoTips => 'Aucun conseil supplémentaire.';

  @override
  String get exerciseDetailFormGuide => 'Guide de forme';

  @override
  String get exerciseDetailOpenHeatmap => 'Ouvrir la carte thermique du corps ciblé';

  @override
  String get exerciseDetailNoHeatmap => 'Aucune zone corporelle ciblée disponible';

  @override
  String get exerciseDetailZoomHint => 'Pincez ou faites glisser pour zoomer';

  @override
  String get exerciseDetailLoadingBestLifts => 'Chargement des meilleures levées';

  @override
  String get exerciseDetailLoadingBestLiftsBody => 'Vos records de séries terminées sont en cours de calcul.';

  @override
  String get exerciseDetailMetricsUnavailable => 'Mesures indisponibles';

  @override
  String get exerciseDetailMetricsUnavailableBody => 'Rouvrez cet exercice pour charger ses records de séries terminées.';

  @override
  String get exerciseDetailNoBestLifts => 'Aucune meilleure levée pour le moment';

  @override
  String get exerciseDetailNoBestLiftsBody => 'Terminez une série avec charge pour cet exercice afin de commencer le suivi des records par répétition.';

  @override
  String get exerciseDetailWeek => 'Semaine';

  @override
  String get exerciseDetailMonth => 'Mois';

  @override
  String get exerciseDetailAllTime => 'Tout temps';

  @override
  String exerciseDetailTimeframeMetrics(String timeframe) {
    return 'Mesures sur $timeframe';
  }

  @override
  String get exerciseDetailTopEstimatedOneRm => 'Meilleur 1RM estimé';

  @override
  String get exerciseDetailVolumeBest => 'Meilleur volume';

  @override
  String get exerciseDetailRepBests => 'Records par répétition';

  @override
  String get exerciseDetailRepBestsBody => 'Meilleur poids terminé pour chaque nombre de répétitions';

  @override
  String exerciseDetailRanges(int count) {
    return '$count plages';
  }

  @override
  String get exerciseDetailHistoryLoadFailed => 'Impossible de charger l’historique de l’exercice.';

  @override
  String get exerciseDetailNoHistory => 'Aucun historique pour cet exercice.';

  @override
  String get exerciseDetailPerformanceTrend => 'Tendance de performance';

  @override
  String get exerciseDetailBestWeight => 'Meilleur poids';

  @override
  String get exerciseDetailEstimatedOneRm => '1RM estimé';

  @override
  String get exerciseDetailLoadingSessions => 'Chargement des séances';

  @override
  String get exerciseDetailLoadMoreSessions => 'Charger 10 séances de plus';

  @override
  String get exerciseDetailResizeLabel => 'Redimensionner les détails de l’exercice';

  @override
  String get exerciseDetailResizeHint => 'Faites glisser vers le haut ou le bas pour redimensionner la fiche';

  @override
  String get exerciseDetailTabDetails => 'Détails';

  @override
  String get exerciseDetailTabMetrics => 'Mesures';

  @override
  String get exerciseDetailTabRecords => 'Records';

  @override
  String exerciseDetailOpenWorkoutWithSets(int count) {
    return 'Ouvrir l’entraînement avec $count séries terminées';
  }

  @override
  String exerciseDetailSetCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count séries',
      one: '1 série',
    );
    return '$_temp0';
  }

  @override
  String exerciseDetailEstimatedMax(String weight) {
    return 'RM estimé $weight';
  }

  @override
  String get exerciseDetailReps => 'rép.';

  @override
  String get exerciseDetailSetVolume => 'Volume de la série';

  @override
  String get exerciseDetailNoChartData => 'Aucun record de série terminée à afficher dans le graphique.';

  @override
  String get exerciseDetailWeightAbbreviation => 'Poids';

  @override
  String get exerciseDetailEstimatedAbbreviation => 'Est.';

  @override
  String get exerciseDetailTopAbbreviation => 'Sommet';

  @override
  String exerciseDetailSectionLabel(String title) {
    return 'Section $title';
  }

  @override
  String get logbookTutorialCalendarTitle => 'Calendrier d’entraînement';

  @override
  String get logbookTutorialCalendarBody => 'Consultez votre activité d’entraînement par jour et utilisez les contrôles de période pour explorer l’historique.';

  @override
  String get fullHistoryTitle => 'Toutes les séances';

  @override
  String get fullHistoryLoadError => 'Impossible de charger les séances enregistrées.';

  @override
  String get fullHistoryEmpty => 'Aucune séance enregistrée.';

  @override
  String fullHistorySessionSummary(String date, int minutes) {
    return '$date - $minutes min';
  }

  @override
  String get weeklySetsTitle => 'Aperçu des séries hebdomadaires';

  @override
  String get weeklySetsLoadError => 'Impossible de charger votre aperçu d’entraînement hebdomadaire.';

  @override
  String get weeklySetsBodyParts => 'Parties du corps';

  @override
  String get weeklySetsMuscles => 'Muscles';

  @override
  String get weeklySetsTotal => 'Total';

  @override
  String get weeklySetsTime => 'Temps';

  @override
  String get weeklySetsVolume => 'Volume';

  @override
  String get weeklySetsNoBodyParts => 'Aucune partie du corps travaillée cette semaine.';

  @override
  String get weeklySetsNoMuscles => 'Aucun muscle travaillé cette semaine.';

  @override
  String weeklySetsCount(String count) {
    return '$count séries';
  }

  @override
  String get weeklySetsTutorialOverviewTitle => 'Aperçu hebdomadaire';

  @override
  String get weeklySetsTutorialOverviewBody => 'Consultez les séries, le temps et le volume accumulés au cours des 7 derniers jours.';

  @override
  String get weeklySetsTutorialAnatomyTitle => 'Travail anatomique';

  @override
  String get weeklySetsTutorialAnatomyBody => 'Passez des parties du corps aux muscles pour voir où votre travail s’est concentré.';

  @override
  String get weeklySetsTutorialStatusTitle => 'État des objectifs';

  @override
  String get weeklySetsTutorialStatusBody => 'Les indicateurs montrent comment votre travail récent se compare aux plages de volume recommandées.';

  @override
  String get workoutDetailTutorialSummaryTitle => 'Résumé de l’entraînement';

  @override
  String get workoutDetailTutorialSummaryBody => 'Consultez le total de séries, le volume, la durée, le nombre d’exercices et les parties du corps travaillées.';

  @override
  String get workoutDetailTutorialExercisesTitle => 'Records d’exercice';

  @override
  String get workoutDetailTutorialExercisesBody => 'Chaque exercice présente les séries terminées de cette séance. Touchez les détails pour examiner l’exercice.';

  @override
  String get workoutDetailTutorialEditTitle => 'Modifier la séance';

  @override
  String get workoutDetailTutorialEditBody => 'Utilisez le mode modification pour corriger les séries, les répétitions ou les exercices après l’entraînement.';

  @override
  String get workoutDetailTutorialReuseTitle => 'Réutiliser cet entraînement';

  @override
  String get workoutDetailTutorialReuseBody => 'Refaites l’entraînement ou enregistrez la séance terminée comme plan réutilisable.';

  @override
  String get workoutDetailDeleteTitle => 'Supprimer la séance';

  @override
  String get workoutDetailDeleteBody => 'Voulez-vous vraiment supprimer cette séance?';

  @override
  String get workoutDetailDeleteFailed => 'Impossible de supprimer cette séance.';

  @override
  String get workoutDetailChangesSaved => 'Modifications enregistrées.';

  @override
  String get workoutDetailSaveFailed => 'Impossible d’enregistrer les modifications. La séance précédente reste inchangée.';

  @override
  String get workoutDetailFinishCurrentFirst => 'Terminez votre entraînement en cours avant de refaire celui-ci.';

  @override
  String get workoutDetailOngoingWorkoutKept => 'Votre entraînement en cours a été conservé. Terminez-le ou annulez-le avant de refaire cet entraînement.';

  @override
  String get workoutDetailRepeatFailed => 'Impossible de refaire cet entraînement.';

  @override
  String get workoutDetailSaveAsPlan => 'Enregistrer comme plan';

  @override
  String get workoutDetailPlanName => 'Nom du plan';

  @override
  String workoutDetailPlanSaved(String name) {
    return '« $name » a été enregistré comme plan.';
  }

  @override
  String get workoutDetailPlanSaveFailed => 'Impossible d’enregistrer le plan.';

  @override
  String workoutDetailDefaultPlanName(String date) {
    return 'Entraînement $date';
  }

  @override
  String get workoutDetailUnsavedTitle => 'Modifications non enregistrées';

  @override
  String get workoutDetailUnsavedBody => 'Vous avez des modifications non enregistrées. Voulez-vous les ignorer et quitter?';

  @override
  String get workoutDetailDiscard => 'Ignorer';

  @override
  String get workoutDetailTitle => 'Détail de l\'entraînement';

  @override
  String get workoutDetailStopEditing => 'Arrêter la modification';

  @override
  String get workoutDetailEditSession => 'Modifier la séance';

  @override
  String get workoutDetailDeleteSession => 'Supprimer la séance';

  @override
  String get workoutDetailLoadFailed => 'Impossible de charger cette séance.';

  @override
  String get workoutDetailEmpty => 'Aucun exercice dans cette séance.';

  @override
  String get workoutDetailSaveChanges => 'Enregistrer les modifications';

  @override
  String get workoutDetailRepeat => 'Refaire l\'entraînement';

  @override
  String get workoutDetailPastWorkout => 'Entraînement passé';

  @override
  String workoutDetailCompletedSets(int count) {
    return '$count séries terminées';
  }

  @override
  String get workoutDetailVolume => 'Volume';

  @override
  String get workoutDetailDuration => 'Durée';

  @override
  String get workoutDetailExercises => 'Exercices';

  @override
  String get workoutDetailExerciseInfo => 'Informations sur l’exercice';

  @override
  String get workoutDetailBest => 'Meilleur';

  @override
  String workoutDetailEstimatedOneRm(String weight) {
    return '1RM = $weight';
  }

  @override
  String get logbookCalendarLoadFailed => 'Impossible de charger le calendrier d’entraînement.';

  @override
  String get logbookNoWorkouts => 'Aucun entraînement enregistré.';

  @override
  String logbookWorkoutCount(int count) {
    return '$count entraînements';
  }

  @override
  String get logbookPreviousMonth => 'Mois précédent';

  @override
  String get logbookNextMonth => 'Mois suivant';

  @override
  String get logbookPreviousThreeMonths => 'Trois mois précédents';

  @override
  String get logbookNextThreeMonths => 'Trois mois suivants';

  @override
  String get logbookPreviousYear => 'Année précédente';

  @override
  String get logbookNextYear => 'Année suivante';

  @override
  String logbookWeekShort(int week) {
    return 'Sem.';
  }

  @override
  String logbookMonthWeek(String month, int week) {
    return 'Mois / semaine';
  }

  @override
  String get logbookWorkouts => 'Entraînements';

  @override
  String get logbookTotalTime => 'Temps total';

  @override
  String get logbookTotalVolume => 'Volume total';

  @override
  String get logbookViewAllSessions => 'Voir toutes les séances';

  @override
  String logbookSessionSummary(int minutes, int exercises, int sets, String volume) {
    String _temp0 = intl.Intl.pluralLogic(
      exercises,
      locale: localeName,
      other: '$exercises exercices',
      one: '1 exercice',
    );
    String _temp1 = intl.Intl.pluralLogic(
      sets,
      locale: localeName,
      other: '$sets séries',
      one: '1 série',
    );
    return '$minutes min - $_temp0 - $_temp1 - $volume';
  }

  @override
  String durationHours(int hours) {
    return '$hours heure(s)';
  }

  @override
  String durationMinutes(int minutes) {
    return '$minutes minute(s)';
  }

  @override
  String durationSeconds(int seconds) {
    return '$seconds seconde(s)';
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
  String get dashboardHideSection => 'Masquer la section';

  @override
  String get dashboardAllSectionsShown => 'Toutes les sections sont affichées';

  @override
  String dashboardHiddenSectionCount(int count) {
    return '$count section(s) masquée(s)';
  }

  @override
  String get dashboardShowHiddenSections => 'Afficher les sections masquées';

  @override
  String get dashboardReset => 'Réinitialiser le tableau de bord';

  @override
  String get dashboardEmptyTitle => 'Votre tableau de bord est vide';

  @override
  String get dashboardEmptyBody => 'Ajoutez de nouveau une section lorsque vous serez prêt.';

  @override
  String get dashboardCustomize => 'Personnaliser le tableau de bord';

  @override
  String get dashboardSectionQuickActionsTitle => 'Actions rapides';

  @override
  String get dashboardSectionQuickActionsBody => 'Enregistrez une mesure ou commencez un entraînement.';

  @override
  String get dashboardSectionTrainingTitle => 'Prêt à vous entraîner';

  @override
  String get dashboardSectionTrainingBody => 'Sélectionnez votre profil de salle, vos plans et commencez une séance.';

  @override
  String get dashboardSectionNutritionTitle => 'Tableau de bord nutritionnel';

  @override
  String get dashboardSectionNutritionBody => 'Consultez vos objectifs actuels de calories et de macronutriments.';

  @override
  String get dashboardSectionDataRecordsTitle => 'Données et records';

  @override
  String get dashboardSectionDataRecordsBody => 'Consultez et ajoutez des entrées nutritionnelles quotidiennes.';

  @override
  String get dashboardSectionWeeklyFocusTitle => 'Priorité hebdomadaire';

  @override
  String get dashboardSectionWeeklyFocusBody => 'Consultez le travail par partie du corps et muscle des 7 derniers jours.';

  @override
  String get dashboardSectionWorkoutReportTitle => 'Rapport d’entraînement';

  @override
  String get dashboardSectionWorkoutReportBody => 'Comparez le nombre, le temps et le volume des entraînements au fil du temps.';

  @override
  String get dashboardSectionExerciseProgressTitle => 'Progrès des exercices';

  @override
  String get dashboardSectionExerciseProgressBody => 'Suivez les tendances de force de vos exercices sélectionnés.';

  @override
  String get dashboardSectionHistoryTitle => 'Historique d’entraînement';

  @override
  String get dashboardSectionHistoryBody => 'Comparez les totaux et le travail ciblé selon différentes périodes.';

  @override
  String get dashboardSectionHealthTrendsTitle => 'Tendances santé';

  @override
  String get dashboardSectionHealthTrendsBody => 'Suivez les mesures comme le poids corporel et les mensurations.';

  @override
  String get dashboardSectionRecentWorkoutsTitle => 'Entraînements récents';

  @override
  String get dashboardSectionRecentWorkoutsBody => 'Ouvrez vos dernières séances d’entraînement terminées.';

  @override
  String get dashboardSectionActivePlansTitle => 'Plans actifs';

  @override
  String get dashboardSectionActivePlansBody => 'Gardez vos plans les plus utilisés à portée de main.';

  @override
  String get dashboardSectionArchivedPlansTitle => 'Plans archivés';

  @override
  String get dashboardSectionArchivedPlansBody => 'Parcourez les plans qui ne sont pas actifs actuellement.';

  @override
  String get dashboardSectionPremadePlansTitle => 'Plans prédéfinis';

  @override
  String get dashboardSectionPremadePlansBody => 'Parcourez les routines qui peuvent être ajoutées à ce profil.';

  @override
  String get dashboardSectionPlanToolsTitle => 'Outils de planification';

  @override
  String get dashboardSectionPlanToolsBody => 'Générez un plan équilibré ou créez-en un manuellement.';

  @override
  String get dashboardSectionCatalogTitle => 'Catalogue d’exercices';

  @override
  String get dashboardSectionCatalogBody => 'Ouvrez vos exercices les plus utilisés et le catalogue complet.';

  @override
  String get dashboardSectionAnatomyTitle => 'Anatomie ciblée';

  @override
  String get dashboardSectionAnatomyBody => 'Consultez les parties du corps et les muscles que vous entraînez le plus.';

  @override
  String get dashboardSectionFallbackTitle => 'Section du tableau de bord';

  @override
  String get dashboardSectionFallbackBody => 'Une section du tableau de bord.';

  @override
  String get dashboardTitle => 'Tableau de bord';

  @override
  String get dashboardDoneCustomizing => 'Terminer la personnalisation';

  @override
  String get dashboardQuickActions => 'Actions rapides';

  @override
  String get dashboardMeasurement => 'Mesure';

  @override
  String get dashboardResumeWorkout => 'Reprendre l’entraînement';

  @override
  String get dashboardStartWorkout => 'Commencer l’entraînement';

  @override
  String dashboardTodayAt(String time) {
    return 'Aujourd’hui, $time';
  }

  @override
  String get dashboardRecentWorkouts => 'Entraînements récents';

  @override
  String get dashboardViewAll => 'Tout afficher';

  @override
  String get dashboardRecentWorkoutsFailed => 'Impossible de charger les entraînements récents.';

  @override
  String get dashboardRecentWorkoutsEmpty => 'Terminez un entraînement et il apparaîtra ici.';

  @override
  String get userInfoProfileUpdateNote => 'Ces renseignements sont utilisés pour personnaliser les calculs et recommandations de l’application.';

  @override
  String get userInfoChangesSaved => 'Modifications enregistrées.';

  @override
  String get userInfoSaveFailed => 'Impossible d’enregistrer vos modifications.';

  @override
  String get userInfoTitle => 'Renseignements personnels';

  @override
  String get userInfoSubtitle => 'Gérez vos détails personnels, vos mesures corporelles et votre profil d’activité.';

  @override
  String get userInfoIdentityTitle => 'Identité';

  @override
  String get userInfoIdentitySubtitle => 'Informations utilisées pour personnaliser votre expérience.';

  @override
  String get userInfoName => 'Nom';

  @override
  String get userInfoNameHint => 'Entrez votre nom';

  @override
  String get userInfoGender => 'Genre';

  @override
  String get userInfoDateOfBirth => 'Date de naissance';

  @override
  String get userInfoDateHint => 'Sélectionnez votre date de naissance';

  @override
  String get userInfoBodyMetricsTitle => 'Mesures corporelles';

  @override
  String get userInfoBodyMetricsSubtitle => 'Informations utilisées par les calculs de santé et d’entraînement.';

  @override
  String get userInfoHeight => 'Taille';

  @override
  String get userInfoHeightHint => 'p. ex. 5 pi 10 po ou 178 cm';

  @override
  String get userInfoCurrentWeight => 'Poids actuel';

  @override
  String get userInfoWeightPoundsHint => 'p. ex. 160';

  @override
  String get userInfoWeightKilogramsHint => 'p. ex. 72';

  @override
  String get userInfoBodyFat => 'Masse grasse';

  @override
  String get userInfoActivityTitle => 'Activité';

  @override
  String get userInfoActivitySubtitle => 'Préférences qui aident à estimer les besoins d’activité et de récupération.';

  @override
  String get userInfoWeightTrend => 'Tendance du poids';

  @override
  String get userInfoAverageSteps => 'Pas moyens';

  @override
  String get userInfoGenderMale => 'Homme';

  @override
  String get userInfoGenderFemale => 'Femme';

  @override
  String get userInfoGenderOther => 'Autre';

  @override
  String get userInfoGenderPreferNotToSay => 'Je préfère ne pas répondre';

  @override
  String get userInfoTrendGaining => 'En hausse';

  @override
  String get userInfoTrendLosing => 'En baisse';

  @override
  String get userInfoTrendMaintaining => 'Stable';

  @override
  String get userInfoTrendNotSure => 'Je ne sais pas';

  @override
  String get userInfoActivityLow => 'Faible';

  @override
  String get userInfoActivityModerate => 'Modérée';

  @override
  String get userInfoActivityHigh => 'Élevée';

  @override
  String get userInfoSaveChanges => 'Enregistrer les modifications';

  @override
  String get tutorialsSettingsTitle => 'Tutoriels guidés';

  @override
  String get tutorialsSettingsSubtitle => 'Rejouez un guide lorsque vous avez besoin d’un rappel rapide.';

  @override
  String get tutorialsControlsTitle => 'Contrôles des tutoriels';

  @override
  String get tutorialsControlsSubtitle => 'Vous testez ou voulez repartir de zéro?';

  @override
  String get tutorialsResetAllTitle => 'Réinitialiser tous les tutoriels';

  @override
  String get tutorialsResetAllSubtitle => 'Rend chaque tutoriel guidé disponible de nouveau.';

  @override
  String get tutorialsResetAll => 'Tout réinitialiser';

  @override
  String get tutorialsResetAllMessage => 'Tous les tutoriels ont été réinitialisés.';

  @override
  String get tutorialsHowItWorksTitle => 'Fonctionnement des tutoriels';

  @override
  String get tutorialsHowItWorksBody => 'Les tutoriels s’affichent une fois, puis restent discrets. Développez un groupe pour réinitialiser un guide précis.';

  @override
  String get tutorialsMainTabsTitle => 'Onglets principaux';

  @override
  String get tutorialsMainTabsSubtitle => 'Rejouez les guides de chaque zone principale.';

  @override
  String get tutorialsWorkoutTitle => 'Entraînement';

  @override
  String get tutorialsWorkoutSubtitle => 'Aide pour enregistrer votre première séance.';

  @override
  String get tutorialsPlansTitle => 'Plans et entraînements';

  @override
  String get tutorialsPlansSubtitle => 'Rejouez l’aide pour créer et modifier des plans, ainsi que les détails d’entraînement.';

  @override
  String get tutorialsCatalogTitle => 'Catalogue et anatomie';

  @override
  String get tutorialsCatalogSubtitle => 'Rejouez les guides des exercices et de l’anatomie ciblée.';

  @override
  String get tutorialsProgressTitle => 'Progrès et réglages';

  @override
  String get tutorialsProgressSubtitle => 'Rejouez l’aide des détails de progrès et des pages de réglages.';

  @override
  String tutorialsReplayTitle(String topic) {
    return 'Rejouer le tutoriel : $topic';
  }

  @override
  String tutorialsShownNextTime(String topic) {
    return 'S’affichera la prochaine fois que vous ouvrirez $topic.';
  }

  @override
  String tutorialsWillReplayNextTime(String topic) {
    return 'Le tutoriel « $topic » sera rejoué la prochaine fois.';
  }

  @override
  String get tutorialsReset => 'Réinitialiser';

  @override
  String get tutorialsTopicTrain => 'Entraînement';

  @override
  String get tutorialsTopicCatalog => 'Catalogue';

  @override
  String get tutorialsTopicLogbook => 'Journal';

  @override
  String get tutorialsTopicProgress => 'Progrès';

  @override
  String get tutorialsTopicProfile => 'Profil';

  @override
  String get tutorialsTopicFirstWorkout => 'premier entraînement';

  @override
  String get tutorialsTopicGeneratePlans => 'Générer des plans';

  @override
  String get tutorialsTopicOptimizedSettings => 'réglages d’entraînement optimisé';

  @override
  String get tutorialsTopicPremadePlans => 'plans prédéfinis';

  @override
  String get tutorialsTopicPlanManagement => 'gestion des plans';

  @override
  String get tutorialsTopicPlanDetail => 'détails du plan';

  @override
  String get tutorialsTopicPlanBuilder => 'création de plan';

  @override
  String get tutorialsTopicWorkoutDetail => 'détails d’entraînement';

  @override
  String get tutorialsTopicExerciseCatalog => 'Catalogue d’exercices';

  @override
  String get tutorialsTopicExerciseDetail => 'détails de l’exercice';

  @override
  String get tutorialsTopicTargetAnatomy => 'anatomie ciblée';

  @override
  String get tutorialsTopicBodypartDetail => 'détails de la partie du corps';

  @override
  String get tutorialsTopicMuscleDetail => 'détails du muscle';

  @override
  String get tutorialsTopicWeeklySets => 'aperçu des séries hebdomadaires';

  @override
  String get tutorialsTopicExerciseProgress => 'progrès de l’exercice';

  @override
  String get tutorialsTopicMeasurementTrend => 'tendance de la mesure';

  @override
  String get tutorialsTopicGymProfile => 'éditeur de profil de salle';

  @override
  String get tutorialsTopicUiAppearance => 'interface et apparence';

  @override
  String get tutorialsTopicDatabaseSettings => 'réglages de la base de données';

  @override
  String get tutorialsTopicGuide => 'aide guidée';

  @override
  String get anatomyLibraryTitle => 'Bibliothèque d’anatomie ciblée';

  @override
  String get anatomyBodyParts => 'Parties du corps';

  @override
  String get anatomyMuscles => 'Muscles';

  @override
  String get anatomyLoadFailed => 'Impossible de charger les filtres d’anatomie.';

  @override
  String get anatomySearchLabel => 'Rechercher des parties du corps ou des muscles';

  @override
  String get anatomyNoBodyParts => 'Aucune partie du corps trouvée.';

  @override
  String get anatomyNoMuscles => 'Aucun muscle trouvé.';

  @override
  String anatomyExerciseCount(int count) {
    return '$count exercices';
  }

  @override
  String get anatomyTutorialSearchTitle => 'Rechercher dans l’anatomie';

  @override
  String get anatomyTutorialSearchBody => 'Recherchez une partie du corps ou un muscle pour ouvrir rapidement ses exercices et données associées.';

  @override
  String get anatomyTutorialListsTitle => 'Listes d’anatomie';

  @override
  String get anatomyTutorialListsBody => 'Basculez entre les parties du corps et les muscles pour explorer les zones que vos exercices ciblent.';

  @override
  String anatomyTargetExercises(String name) {
    return 'Exercices ciblés';
  }

  @override
  String get anatomyBodypartLoadFailed => 'Impossible de charger les détails de la partie du corps.';

  @override
  String get anatomyMuscleLoadFailed => 'Impossible de charger les détails du muscle.';

  @override
  String anatomyRecommendedSetsUpdated(String name) {
    return 'Séries recommandées mises à jour.';
  }

  @override
  String get anatomySaveFailed => 'Impossible d’enregistrer les modifications.';

  @override
  String anatomyLinkedExerciseCount(int count) {
    return '$count exercices associés';
  }

  @override
  String get anatomyDoneLastSevenDays => 'Fait au cours des 7 derniers jours';

  @override
  String get anatomySetsLastSevenDays => 'Séries des 7 derniers jours';

  @override
  String anatomySetUnits(String count) {
    return 'unités de séries';
  }

  @override
  String get anatomyRecommended => 'Recommandé';

  @override
  String get anatomyNotSet => 'Non défini';

  @override
  String anatomySetRange(String min, String max) {
    return 'Plage de séries';
  }

  @override
  String get anatomyAssociatedMuscles => 'Muscles associés';

  @override
  String get anatomyRelatedBodyParts => 'Parties du corps liées';

  @override
  String get anatomyNoMuscleLinks => 'Aucun muscle associé.';

  @override
  String get anatomyNoBodyPartLinks => 'Aucune partie du corps liée.';

  @override
  String get anatomyExercises => 'Exercices';

  @override
  String anatomyNoExercisesFor(String name) {
    return 'Aucun exercice pour $name.';
  }

  @override
  String get anatomyNoEquipment => 'Aucun équipement';

  @override
  String get anatomyNoMusclesListed => 'Aucun muscle indiqué.';

  @override
  String get anatomyNoBodyPartsListed => 'Aucune partie du corps indiquée.';

  @override
  String anatomyOpenedFrom(String name) {
    return 'Ouvert depuis $name';
  }

  @override
  String anatomyRankForMuscle(int rank, String bodyparts) {
    return 'Classer $rank pour ce muscle - $bodyparts';
  }

  @override
  String get anatomyTutorialDetailTitle => 'Détails d’anatomie';

  @override
  String get anatomyTutorialBodypartDetailBody => 'Voyez le travail récent, la plage de séries recommandée, les muscles associés et les exercices de cette partie du corps.';

  @override
  String get anatomyTutorialMuscleDetailTitle => 'Détails du muscle';

  @override
  String get anatomyTutorialMuscleDetailBody => 'Voyez le travail récent, la plage de séries recommandée, les parties du corps liées et les exercices de ce muscle.';

  @override
  String get anatomyTutorialLinkedExercisesTitle => 'Exercices associés';

  @override
  String get anatomyTutorialBodypartExercisesBody => 'Ouvrez un exercice pour voir comment il contribue à cette partie du corps.';

  @override
  String get anatomyTutorialMuscleExercisesBody => 'Ouvrez un exercice pour voir comment il contribue à ce muscle.';

  @override
  String get settingsWorkoutTitle => 'Réglages d’entraînement';

  @override
  String get settingsWorkoutSubtitle => 'Ajustez la façon dont l’application comprend l’anatomie, la priorité d’entraînement et les cibles de volume.';

  @override
  String get settingsTrainingBiasTitle => 'Priorité d’entraînement';

  @override
  String get settingsTrainingBiasSubtitle => 'Contrôles utilisés par les plans générés et les entraînements optimisés.';

  @override
  String get settingsBodyPartRankings => 'Classement des parties du corps';

  @override
  String get settingsBodyPartRankingsSubtitle => 'Priorisez les parties du corps qui devraient recevoir plus de travail.';

  @override
  String get settingsMuscleRankings => 'Classement des muscles';

  @override
  String get settingsMuscleRankingsSubtitle => 'Priorisez des muscles précis dans le modèle anatomique.';

  @override
  String get settingsVolumeBoundaries => 'Limites de volume';

  @override
  String get settingsVolumeBoundariesSubtitle => 'Définissez les plages hebdomadaires recommandées pour les parties du corps et les muscles.';

  @override
  String get settingsExerciseDefinitionsTitle => 'Définitions d’exercices';

  @override
  String get settingsExerciseDefinitionsSubtitle => 'Entretenez les données anatomiques et d’exercices utilisées par l’application.';

  @override
  String get settingsAnatomyMapping => 'Correspondance partie du corps / muscle';

  @override
  String get settingsAnatomyMappingSubtitle => 'Choisissez les muscles associés à chaque partie du corps.';

  @override
  String get settingsExerciseSetAllocation => 'Répartition des séries par exercice';

  @override
  String get settingsExerciseSetAllocationSubtitle => 'Consultez la contribution de chaque exercice aux muscles et parties du corps.';

  @override
  String get settingsExerciseEditor => 'Éditeur d’exercices';

  @override
  String get settingsExerciseEditorSubtitle => 'Mettez à jour les noms, détails, équipements et associations des exercices.';

  @override
  String get commonCopy => 'Copier';

  @override
  String get commonImport => 'Importer';

  @override
  String get commonExport => 'Exporter';

  @override
  String get databaseExportTitle => 'Exporter la base de données';

  @override
  String get databaseImportTitle => 'Importer la base de données';

  @override
  String get databasePasteJson => 'Collez le JSON ici';

  @override
  String get databaseCopied => 'Copié dans le presse-papiers';

  @override
  String databaseExportFailed(String error) {
    return 'Échec de l’exportation : $error';
  }

  @override
  String get databaseImportSucceeded => 'Importation réussie';

  @override
  String databaseImportFailed(String error) {
    return 'Échec de l’importation : $error';
  }

  @override
  String get settingsTitle => 'Réglages';

  @override
  String get nutritionSettingsTitle => 'Réglages de l’alimentation et de la nutrition';

  @override
  String get nutritionSettingsSubtitle => 'Configurez les cibles nutritionnelles et les préférences liées aux aliments.';

  @override
  String get nutritionCurrentGoals => 'Objectifs actuels';

  @override
  String get nutritionGoals => 'Objectifs';

  @override
  String get nutritionGoalsSubtitle => 'Définissez les cibles utilisées par le suivi nutritionnel.';

  @override
  String get nutritionManualGoals => 'Définir les objectifs nutritionnels manuellement';

  @override
  String get nutritionManualGoalsSubtitle => 'Entrez vous-même les calories, macronutriments et nutriments clés.';

  @override
  String get nutritionGoalsSaved => 'Objectifs enregistrés';

  @override
  String nutritionGoalSummary(String calories, String protein, String carbs, String fat, String fiber, String sugar, String satFat, String sodium) {
    return 'Calories : $calories / Protéines : $protein / Glucides : $carbs / Lipides : $fat / Fibres : $fiber / Sucre : $sugar / Gras sat. : $satFat / Sodium : $sodium';
  }

  @override
  String get progressSettingsTitle => 'Réglages des progrès';

  @override
  String get progressSettingsSubtitle => 'Configurez les mesures, les tendances et les préférences de suivi.';

  @override
  String get progressMeasurements => 'Mesures';

  @override
  String get progressMeasurementsSubtitle => 'Enregistrez les données corporelles et de santé au fil du temps.';

  @override
  String get progressMeasurementLibrary => 'Bibliothèque de mesures';

  @override
  String get progressMeasurementLibrarySubtitle => 'Créez et gérez les mesures que vous souhaitez suivre.';

  @override
  String get nutritionManualGoalsTitle => 'Objectifs nutritionnels manuels';

  @override
  String get nutritionManualGoalsPageSubtitle => 'Définissez manuellement les cibles de calories, macronutriments et nutriments.';

  @override
  String get nutritionSaveGoals => 'Enregistrer les objectifs';

  @override
  String get nutritionSaving => 'Enregistrement...';

  @override
  String get nutritionStartDate => 'Date de début';

  @override
  String get nutritionGoalStarts => 'L’objectif commence';

  @override
  String get nutritionCaloriesAndMacros => 'Calories et macronutriments';

  @override
  String get nutritionAdditionalNutrients => 'Nutriments supplémentaires';

  @override
  String get nutritionCalories => 'Calories (kcal)';

  @override
  String get nutritionProtein => 'Protéines (g)';

  @override
  String get nutritionCarbs => 'Glucides (g)';

  @override
  String get nutritionFat => 'Lipides (g)';

  @override
  String get nutritionFiber => 'Fibres (g)';

  @override
  String get nutritionSugar => 'Sucre (g)';

  @override
  String get nutritionSatFat => 'Gras sat. (g)';

  @override
  String get nutritionSodium => 'Sodium (mg)';

  @override
  String get nutritionEnterNumber => 'Entrez un nombre';

  @override
  String get nutritionNumberAtLeastZero => 'Doit être >= 0';

  @override
  String rankingsSaved(String target) {
    return 'Classements enregistrés.';
  }

  @override
  String get rankingsSave => 'Enregistrer les classements';

  @override
  String rankingsTitle(String target) {
    return 'Classements';
  }

  @override
  String rankingsHero(String target) {
    return 'Classez vos priorités afin que Tonos puisse mieux répartir le travail dans les entraînements générés.';
  }

  @override
  String get rankingsNoBodyParts => 'Aucune partie du corps disponible.';

  @override
  String get rankingsNoMuscles => 'Aucun muscle disponible.';

  @override
  String rankingsLoadError(String target, String error) {
    return 'Impossible de charger les classements : $error';
  }

  @override
  String rankingsSaveError(String error) {
    return 'Impossible d’enregistrer les classements : $error';
  }

  @override
  String get rankingsRank => 'Classer';

  @override
  String get mappingTitle => 'Correspondance parties du corps et muscles';

  @override
  String get mappingHero => 'Définissez quels muscles appartiennent à chaque partie du corps afin que les analyses et recommandations anatomiques restent cohérentes.';

  @override
  String get mappingSaved => 'Correspondances enregistrées.';

  @override
  String mappingSaveFailed(String error) {
    return 'Impossible d’enregistrer les correspondances : $error';
  }

  @override
  String get mappingSelectedBodyPart => 'Partie du corps sélectionnée';

  @override
  String get mappingBodyPart => 'Partie du corps';

  @override
  String get mappingChooseLinkedMuscles => 'Choisir les muscles associés';

  @override
  String get mappingLinkedMuscles => 'Muscles associés';

  @override
  String get mappingChooseLinkedSubtitle => 'Sélectionnez tous les muscles qui appartiennent à cette partie du corps.';

  @override
  String mappingLinkedCount(int count) {
    return '$count muscles associés';
  }

  @override
  String get mappingNoMuscles => 'Aucun muscle disponible.';

  @override
  String get mappingNoLinkedMuscles => 'Aucun muscle associé pour le moment.';

  @override
  String get volumeMaintenance => 'Entretien';

  @override
  String get volumeMinEffective => 'Minimum efficace';

  @override
  String get volumeMaxAdaptive => 'Maximum adaptatif';

  @override
  String get volumeMaxRecoverable => 'Maximum récupérable';

  @override
  String volumeLoadBodyPartFailed(String error) {
    return 'Impossible de charger les limites des parties du corps : $error';
  }

  @override
  String volumeLoadMuscleFailed(String error) {
    return 'Impossible de charger les limites des muscles : $error';
  }

  @override
  String get volumeBodyPartSaved => 'Limites des parties du corps enregistrées';

  @override
  String get volumeMuscleSaved => 'Limites des muscles enregistrées';

  @override
  String get volumeInvalidNumbers => 'Veuillez entrer des nombres valides';

  @override
  String get volumeBodyParts => 'Parties du corps';

  @override
  String get volumeMuscles => 'Muscles';

  @override
  String get volumeBodyPartTitle => 'Volume par partie du corps';

  @override
  String get volumeBodyPartSubtitle => 'Définissez les plages hebdomadaires utilisées par les analyses et la génération d’entraînements.';

  @override
  String get volumeMuscleTitle => 'Volume musculaire';

  @override
  String get volumeMuscleSubtitle => 'Ajustez précisément les plages hebdomadaires pour chaque muscle.';

  @override
  String get volumeSelection => 'Sélection';

  @override
  String get volumeRecommendedRange => 'Plage recommandée';

  @override
  String get volumeRecommendedRangeSubtitle => 'Les nombres représentent des unités de séries par semaine.';

  @override
  String get volumeSaveBoundaries => 'Enregistrer les limites';

  @override
  String get nutritionDashboardTitle => 'Tableau de bord nutritionnel';

  @override
  String nutritionDashboardError(String error) {
    return 'Impossible de charger la nutrition : $error';
  }

  @override
  String get nutritionMenuTitle => 'Menu nutritionnel';

  @override
  String get nutritionLogFood => 'Enregistrer un aliment';

  @override
  String get nutritionTrackMeasurement => 'Suivre une mesure';

  @override
  String get nutritionMeasuredItems => 'Éléments mesurés';

  @override
  String get nutritionTodayRecords => 'Relevés d’aujourd’hui';

  @override
  String get nutritionGoalsMenu => 'Objectifs nutritionnels';

  @override
  String get measurementWeight => 'Poids';

  @override
  String get measurementHips => 'Hanches';

  @override
  String get measurementShoulders => 'Épaules';

  @override
  String get measurementCalves => 'Mollets';

  @override
  String get measurementTrackNew => 'Suivre une nouvelle mesure';

  @override
  String get barcodeScannerTitle => 'Balayer un code-barres';

  @override
  String get barcodeSwitchCamera => 'Changer de caméra';

  @override
  String get barcodeTorchOn => 'Lampe activée';

  @override
  String get barcodeTorchOff => 'Lampe désactivée';

  @override
  String get barcodeTorchUnavailable => 'La lampe n’est pas disponible sur cet appareil';

  @override
  String get barcodeAlignHint => 'Alignez le code-barres dans le cadre';

  @override
  String get progressTutorialWorkoutReportTitle => 'Rapport d’entraînement';

  @override
  String get progressTutorialWorkoutReportBody => 'Suivez le nombre d’entraînements, le temps d’entraînement et le volume selon différentes périodes. Touchez une mesure pour modifier le graphique.';

  @override
  String get progressTutorialExerciseProgressTitle => 'Progrès des exercices';

  @override
  String get progressTutorialExerciseProgressBody => 'Suivez les tendances de force des exercices sélectionnés. Utilisez la tuile de modification pour ajouter ou retirer des exercices de ce tableau de bord.';

  @override
  String get progressTutorialHealthTrendsTitle => 'Tendances santé';

  @override
  String get progressTutorialHealthTrendsBody => 'Enregistrez ici votre poids corporel et vos mesures personnalisées, puis observez leur évolution au fil du temps.';

  @override
  String get measurementNewTitle => 'Nouvelle mesure';

  @override
  String get measurementPresets => 'Préréglages';

  @override
  String get measurementCustom => 'Personnalisée';

  @override
  String get measurementPresetType => 'Type de préréglage';

  @override
  String get measurementVariation => 'Variation';

  @override
  String get measurementWakeUp => 'Au réveil';

  @override
  String get measurementBedtime => 'Au coucher';

  @override
  String get measurementOverall => 'Global';

  @override
  String get measurementValueWeight => 'Poids';

  @override
  String get measurementUnits => 'Unités';

  @override
  String get measurementFeet => 'Pieds';

  @override
  String get measurementInches => 'Pouces';

  @override
  String get measurementCentimeters => 'Centimètres';

  @override
  String get measurementWithPump => 'Avec congestion';

  @override
  String get measurementWithoutPump => 'Sans congestion';

  @override
  String get measurementName => 'Nom de la mesure';

  @override
  String get measurementNameHint => 'Tour de poitrine, fréquence cardiaque au repos...';

  @override
  String get measurementValue => 'Valeur';

  @override
  String get measurementUnit => 'Unité';

  @override
  String get measurementNote => 'Note';

  @override
  String get measurementOptional => 'Facultatif';

  @override
  String get measurementSaveNew => 'Enregistrer la nouvelle mesure';

  @override
  String get measurementCustomRequired => 'Entrez un nom personnalisé, une valeur et une unité';

  @override
  String measurementDefinitionNotFound(String name) {
    return 'Définition introuvable pour $name';
  }

  @override
  String get measurementInvalidValue => 'Entrez une valeur numérique valide';

  @override
  String get measurementHeight => 'Taille';

  @override
  String get measurementForearm => 'Avant-bras';

  @override
  String get measurementArm => 'Bras';

  @override
  String get measurementNeck => 'Cou';

  @override
  String get measurementChest => 'Poitrine';

  @override
  String get measurementWaist => 'Taille';

  @override
  String get measurementThigh => 'Cuisse';

  @override
  String get measurementInstructionsForearm => 'Mesurez le tour de la partie la plus large de votre avant-bras.';

  @override
  String get measurementInstructionsArm => 'Mesurez le tour de la partie la plus large de votre biceps.';

  @override
  String get measurementInstructionsNeck => 'Mesurez là où le ruban repose droit autour de votre cou.';

  @override
  String get measurementInstructionsShoulder => 'Gardez le ruban droit autour des deltoïdes latéraux.';

  @override
  String get measurementInstructionsChest => 'Mesurez sous les aisselles et au-dessus de la ligne des mamelons.';

  @override
  String get measurementInstructionsWaist => 'Mesurez le tour de votre nombril.';

  @override
  String get measurementInstructionsHip => 'Mesurez le tour de la partie la plus large de vos fessiers.';

  @override
  String get measurementInstructionsThigh => 'Mesurez le tour de la partie la plus large de votre cuisse.';

  @override
  String get measurementInstructionsCalf => 'Mesurez le tour de la partie la plus large de votre mollet.';

  @override
  String get nutritionCaloriesLabel => 'Calories';

  @override
  String get nutritionFatLabel => 'Lipides';

  @override
  String get nutritionProteinLabel => 'Protéines';

  @override
  String get nutritionCarbsLabel => 'Glucides';

  @override
  String nutritionMacroSummary(int calories, int protein, int carbs, int fat) {
    return '$calories kcal | P $protein g | G $carbs g | L $fat g';
  }

  @override
  String get nutritionEditEntry => 'Modifier l’entrée';

  @override
  String get nutritionEditNotAvailable => 'La modification des entrées n’est pas encore disponible';

  @override
  String get nutritionEntryDeleted => 'Entrée supprimée';

  @override
  String get gymProfileEditTitle => 'Modifier le profil de salle';

  @override
  String get gymProfileNewTitle => 'Nouveau profil de salle';

  @override
  String get gymProfileTutorialSpaceTitle => 'Espace d’entraînement';

  @override
  String get gymProfileTutorialSpaceBody => 'Nommez ce profil selon l’endroit où vous vous entraînez, par exemple Gym à domicile, Gym commercial ou Installation de voyage.';

  @override
  String get gymProfileTutorialFindTitle => 'Trouver de l’équipement';

  @override
  String get gymProfileTutorialFindBody => 'Utilisez la recherche lorsque la liste d’équipement devient longue et que vous voulez accéder rapidement à un élément.';

  @override
  String get gymProfileTutorialAvailableTitle => 'Équipement disponible';

  @override
  String get gymProfileTutorialAvailableBody => 'Sélectionnez ce que possède cet espace d’entraînement. Les plans générés et les remplacements s’en servent pour éviter les exercices indisponibles.';

  @override
  String get gymProfileTutorialSaveTitle => 'Enregistrer le profil';

  @override
  String get gymProfileTutorialSaveBody => 'Enregistrer conserve le profil et l’équipement. Annuler demande une confirmation avant d’ignorer les modifications non enregistrées.';

  @override
  String get gymProfileSaveChangesTitle => 'Enregistrer les modifications?';

  @override
  String get gymProfileSaveChangesBody => 'Vous avez des modifications non enregistrées au profil de salle. Les enregistrer avant de quitter?';

  @override
  String get gymProfileKeepEditing => 'Continuer la modification';

  @override
  String get gymProfileDiscard => 'Ignorer';

  @override
  String get gymProfileSelectEquipment => 'Sélectionnez au moins un élément d’équipement.';

  @override
  String gymProfileSaveFailed(String error) {
    return 'Impossible d’enregistrer le profil : $error';
  }

  @override
  String get gymProfileEquipmentHint => 'Choisissez ce que possède cette salle afin que les plans générés utilisent seulement l’équipement disponible.';

  @override
  String get gymProfileSpace => 'Espace d’entraînement';

  @override
  String gymProfileEquipmentSelected(int selected, int total) {
    return '$selected options d’équipement sélectionnées sur $total';
  }

  @override
  String get gymProfileName => 'Nom du profil';

  @override
  String get gymProfileNameHint => 'Gym à domicile, gym commercial, installation de voyage...';

  @override
  String get gymProfileNameRequired => 'Le nom est requis';

  @override
  String get gymProfileFilterEquipment => 'Filtrer l’équipement par nom';

  @override
  String get gymProfileEquipment => 'Équipement';

  @override
  String get gymProfileSelectAll => 'Tout sélectionner';

  @override
  String get gymProfileClear => 'Effacer';

  @override
  String gymProfileSelectedCount(int selected, int total) {
    return '$selected/$total sélectionnés';
  }

  @override
  String get gymProfileSave => 'Enregistrer le profil';

  @override
  String get gymProfileSaving => 'Enregistrement...';

  @override
  String gymProfileNoEquipmentMatch(String query) {
    return 'Aucun équipement ne correspond à « $query ».';
  }

  @override
  String get equipmentCategoryBasics => 'Équipement de base';

  @override
  String get equipmentCategoryFreeWeights => 'Poids libres';

  @override
  String get equipmentCategoryBenchesRacks => 'Bancs et cages';

  @override
  String get equipmentCategoryCableAttachments => 'Câbles et accessoires';

  @override
  String get equipmentCategoryMachines => 'Machines';

  @override
  String get equipmentCategoryOther => 'Autre équipement';

  @override
  String get equipmentNoRequirement => 'Aucun équipement requis';

  @override
  String get equipmentBodyweightSupport => 'Soutien pour exercices au poids du corps';

  @override
  String get equipmentMachineBased => 'Mouvement sur machine';

  @override
  String get equipmentCableAccessory => 'Accessoire de station à câbles';

  @override
  String get equipmentBenchRackSetup => 'Installation avec banc ou cage';

  @override
  String get equipmentFreeWeightTraining => 'Entraînement avec poids libres';

  @override
  String get equipmentAvailable => 'Équipement disponible';

  @override
  String get foodLoggingTitle => 'Journal alimentaire';

  @override
  String get foodLogTime => 'Heure d’enregistrement :';

  @override
  String get foodPortion => 'Portion :';

  @override
  String get foodQuantity => 'Qté :';

  @override
  String foodGramsPerUnit(int grams) {
    return '$grams g / unité';
  }

  @override
  String get foodRemove => 'Retirer';

  @override
  String get foodAddAllToDiary => 'Tout ajouter au journal';

  @override
  String get foodLogging => 'Enregistrement...';

  @override
  String get foodTabScan => 'Balayer';

  @override
  String get foodTabSearch => 'Rechercher';

  @override
  String get foodTabPlanned => 'Prévu';

  @override
  String get foodTabCustom => 'Personnalisé';

  @override
  String get foodSearchHint => 'Rechercher un aliment...';

  @override
  String get foodNoRecentRecipes => 'Aucune recette récente pour le moment.';

  @override
  String get foodRecentRecipe => 'Recette récente';

  @override
  String get foodNoFoodsFound => 'Aucun aliment trouvé.';

  @override
  String get foodInstantLogAfterScan => 'Enregistrer immédiatement après le balayage';

  @override
  String get foodInstantLogAfterScanSubtitle => 'Ajoutez immédiatement l’élément balayé au repas sélectionné.';

  @override
  String get foodOpenCameraScanner => 'Ouvrir le lecteur de caméra';

  @override
  String get foodEnterBarcode => 'Entrer le code-barres manuellement';

  @override
  String get foodEnterBarcodeHint => 'p. ex. 012345678905';

  @override
  String get foodLogByBarcode => 'Enregistrer par code-barres';

  @override
  String get foodNoBarcode => 'Aucun code-barres valide détecté';

  @override
  String get foodBarcodeLogged => 'Élément enregistré depuis le code-barres';

  @override
  String foodFailed(String error) {
    return 'Échec : $error';
  }

  @override
  String get foodCustomSavedBarcode => 'Aliment personnalisé enregistré et code-barres associé';

  @override
  String get foodFavorites => 'Favoris';

  @override
  String get foodRecentFoods => 'Aliments récents';

  @override
  String get foodStartSearching => 'Commencez une recherche pour trouver des aliments.';

  @override
  String get foodFavorite => 'Ajouter aux favoris';

  @override
  String get foodUnfavorite => 'Retirer des favoris';

  @override
  String get foodCustomize => 'Personnaliser l’aliment';

  @override
  String get foodEditAndAdd => 'Modifier et ajouter';

  @override
  String get foodAddOne => 'Ajouter 1';

  @override
  String get foodAddNew => 'Ajouter un nouvel aliment';

  @override
  String get foodCustomSaved => 'Aliment personnalisé enregistré';

  @override
  String get foodNoteOptional => 'Note (facultative)';

  @override
  String get foodTagsHint => 'Étiquettes (séparées par des virgules, p. ex. après entraînement, riche en protéines)';

  @override
  String get foodAddToPlate => 'Ajouter à l’assiette';

  @override
  String get foodProfileNotReady => 'Le profil n’est pas encore prêt.';

  @override
  String get foodItemsLogged => 'Éléments enregistrés au journal';

  @override
  String foodLogFailed(String error) {
    return 'Impossible d’enregistrer : $error';
  }

  @override
  String get tutorialSkip => 'Passer';

  @override
  String get tutorialSkipAll => 'Tout passer';

  @override
  String get tutorialDone => 'Terminé';

  @override
  String get tutorialNext => 'Suivant';

  @override
  String get tutorialSkipAllTitle => 'Passer tous les tutoriels?';

  @override
  String get tutorialSkipAllBody => 'Cette action masque tous les tutoriels guidés. Vous pourrez les réactiver en tout temps dans Paramètres > Tutoriels guidés en utilisant Réinitialiser tous les tutoriels.';

  @override
  String get tutorialKeep => 'Conserver les tutoriels';

  @override
  String get tutorialSkipEverything => 'Tout passer';

  @override
  String get flowSelectNode => 'Sélectionner un nœud';

  @override
  String get flowSelectMethod => 'Sélectionner une action';

  @override
  String get flowAddSuccess => '+ Réussite';

  @override
  String get flowAddFailure => '+ Échec';

  @override
  String get flowAddMethod => '+ Action';

  @override
  String get flowRemoveMethod => '- Action';

  @override
  String get flowNewEvent => 'Nouvel événement';

  @override
  String get flowEventKey => 'Clé d’événement';

  @override
  String get flowEventDisplayLabel => 'Libellé affiché (facultatif)';

  @override
  String get flowAddSuccessNode => 'Ajouter un nœud de réussite';

  @override
  String get flowAddFailureNode => 'Ajouter un nœud d’échec';

  @override
  String get flowAddEvent => '+ Événement';

  @override
  String get flowSelectEvent => 'Sélectionner un événement';

  @override
  String get flowRemoveEvent => 'Supprimer l’événement';

  @override
  String get drawerNavigation => 'Navigation';

  @override
  String get drawerOptionA => 'Option A';

  @override
  String get drawerOptionB => 'Option B';

  @override
  String get drawerOptionC => 'Option C';

  @override
  String get drawerGymProfiles => 'Profils de salle';

  @override
  String drawerSavedSpaces(int count) {
    return '$count espaces enregistrés';
  }

  @override
  String drawerProfileActive(String name) {
    return '$name est actif';
  }

  @override
  String get drawerActiveProfile => 'Profil actif';

  @override
  String get drawerTapToSwitch => 'Touchez pour changer';

  @override
  String get drawerNewProfile => 'Nouveau profil';

  @override
  String get commonAdd => 'Ajouter';

  @override
  String get commonRemove => 'Retirer';

  @override
  String get automaticSaving => 'Enregistrement...';

  @override
  String get automaticValuesTab => 'Valeurs';

  @override
  String get automaticMethodsTab => 'Méthodes';

  @override
  String get automaticGlobalIncrement => 'Valeur d’incrément global';

  @override
  String get automaticAutoSelect => 'Sélection automatique';

  @override
  String get automaticManualSelect => 'Sélection manuelle';

  @override
  String get automaticSkipFirstSet => 'Ignorer la première série?';

  @override
  String automaticSetLabel(int number, String weight, int reps) {
    return 'Série $number : $weight x $reps';
  }

  @override
  String automaticChildSetLabel(int parent, int child, String weight, int reps) {
    return 'Série $parent.$child : $weight x $reps';
  }

  @override
  String automaticSaveFailed(String error) {
    return 'Impossible d’enregistrer les réglages : $error';
  }

  @override
  String get automaticIncrementWhen => 'Augmenter lorsque (diminuer sinon) :';

  @override
  String get automaticWeightTarget => 'Poids terminé >= poids cible';

  @override
  String get automaticRepsTarget => 'Répétitions terminées >= répétitions cibles';

  @override
  String get automaticVolumeTarget => 'Volume terminé >= volume cible';

  @override
  String get automaticScopeLabel => 'Les réussites, échecs et ajustements sont comptés par :';

  @override
  String get automaticWorkoutSession => 'Séance d’entraînement';

  @override
  String get automaticPerExercise => 'Par exercice';

  @override
  String get automaticPerSet => 'Par série';

  @override
  String get automaticAdjustScope => 'Ajuster :';

  @override
  String get automaticAdjustOneSet => '1 série';

  @override
  String get automaticAdjustAllSets => 'Toutes les séries';

  @override
  String get weightExpandSets => 'Développer les séries';

  @override
  String get weightCollapseSets => 'Réduire les séries';

  @override
  String get weightDetails => 'Détails';

  @override
  String get weightRemoveExerciseTitle => 'Retirer l’exercice';

  @override
  String get weightRemoveExerciseBody => 'Voulez-vous vraiment retirer cet exercice?';

  @override
  String get weightSwapExercise => 'Remplacer l’exercice';

  @override
  String get weightMakeChangeSet => 'Créer une série de remplacement';

  @override
  String weightSetLabel(int number) {
    return 'Série $number';
  }

  @override
  String weightLabel(String unit) {
    return 'Poids ($unit)';
  }

  @override
  String get weightReps => 'Répétitions';

  @override
  String get weightRemoveSetTitle => 'Retirer la série';

  @override
  String get weightRemoveSetBody => 'Voulez-vous vraiment retirer cette série?';

  @override
  String weightChangeSetLabel(int number) {
    return 'Série mod. $number';
  }

  @override
  String weightShortLabel(String unit) {
    return 'Poids ($unit)';
  }

  @override
  String get weightRemoveChangeSetTitle => 'Retirer la série modifiée';

  @override
  String get weightRemoveChangeSetBody => 'Voulez-vous vraiment retirer cette série modifiée?';

  @override
  String get weightAddChangeSet => 'Ajouter une série modifiée';

  @override
  String get weightAddSet => 'Ajouter une série';

  @override
  String get swapAlreadySelected => 'Cet exercice est déjà sélectionné.';

  @override
  String get swapNeedsProfileEquipment => 'Cet exercice nécessite de l’équipement qui ne figure pas dans ce profil.';

  @override
  String swapLoadFailed(Object error) {
    return 'Impossible de charger cet exercice de remplacement.';
  }

  @override
  String get swapCurrent => 'Actuel';

  @override
  String get swapReplacement => 'Remplacement';

  @override
  String get swapConfirm => 'Confirmer le remplacement';

  @override
  String get swapNoBodypartData => 'Aucune donnée de partie du corps trouvée.';

  @override
  String get swapLoadingSelected => 'Chargement de l’exercice sélectionné...';

  @override
  String get swapBrowseCatalog => 'Parcourir le catalogue d’exercices';

  @override
  String get swapNoEquipment => 'Aucun équipement indiqué';

  @override
  String get swapTitle => 'Remplacer l’exercice';

  @override
  String get swapFindingMatches => 'Recherche de correspondances similaires de parties du corps et de muscles...';

  @override
  String get swapChooseReplacement => 'Choisissez un remplacement similaire.';

  @override
  String get swapFilterProfileEquipment => 'Filtrer selon l’équipement du profil';

  @override
  String get swapBodypartsHit => 'Parties du corps travaillées';

  @override
  String swapMatch(int percent) {
    return 'Correspondance à $percent %';
  }

  @override
  String get swapNoReplacements => 'Aucun remplacement similaire trouvé pour le moment.';

  @override
  String get swapNoReplacementsBody => 'Cet exercice peut nécessiter plus de métadonnées musculaires ou de parties du corps avant de pouvoir être bien remplacé.';

  @override
  String get premadePlansTitle => 'Plans prédéfinis';

  @override
  String get premadeTutorialLengthTitle => 'Durée du plan';

  @override
  String get premadeTutorialLengthBody => 'Passez entre les versions de 1 heure et de 2 heures. Les versions plus longues comprennent plus d’exercices et de séries au total.';

  @override
  String get premadeTutorialEquipmentTitle => 'Équipement du profil';

  @override
  String get premadeTutorialEquipmentBody => 'Lorsque cette option est activée, Tonos remplace les exercices indisponibles par des options similaires réalisables avec votre profil de salle actuel.';

  @override
  String get premadeTutorialLibraryTitle => 'Bibliothèque de plans';

  @override
  String get premadeTutorialLibraryBody => 'Ouvrez une répartition, prévisualisez un plan, puis ajoutez-le à vos plans actifs pour le voir dans Entraînement.';

  @override
  String get premadeSelectProfile => 'Sélectionnez d’abord un profil de salle.';

  @override
  String premadePlanAdded(String name) {
    return '$name a été ajouté aux plans actifs.';
  }

  @override
  String premadePlanAddFailed(String name, String error) {
    return 'Impossible d’ajouter $name : $error';
  }

  @override
  String get premadeDescription => 'Copiez des routines de coachs, d’influenceurs et sélectionnées par l’application dans vos propres plans. Une fois ajoutées, vous pouvez les modifier comme n’importe quel autre plan.';

  @override
  String get premadeDiscarding => 'Annulation...';

  @override
  String get premadeReviewPlans => 'Examiner les plans';

  @override
  String get allocationSaveChanges => 'Enregistrer les modifications';

  @override
  String get allocationSaving => 'Enregistrement';

  @override
  String get allocationInvalidCredit => 'Entrez zéro ou un nombre positif pour chaque crédit.';

  @override
  String get allocationSaved => 'Répartition de l’exercice enregistrée.';

  @override
  String get allocationSaveFailed => 'Impossible d’enregistrer la répartition de l’exercice. Réessayez.';

  @override
  String get allocationSaveOrDiscard => 'Enregistrez ou ignorez vos modifications avant de réinitialiser.';

  @override
  String get allocationTitle => 'Répartition des séries par exercice';

  @override
  String get allocationSubtitle => 'Consultez la contribution des séries terminées aux muscles et parties du corps ciblés.';

  @override
  String get allocationHowTitle => 'Fonctionnement du crédit par série';

  @override
  String get allocationHowBody => 'Un muscle principal reçoit habituellement un crédit de 1,00 pour une série terminée. Les muscles de soutien reçoivent moins de crédit. Cela oriente les résumés anatomiques et les recommandations, sans jamais modifier les séries enregistrées.';

  @override
  String allocationLoadFailed(String error) {
    return 'Impossible de charger les exercices. $error';
  }

  @override
  String get allocationNoExercises => 'Aucun exercice n’est encore disponible.';

  @override
  String get allocationSelectedExercise => 'Exercice sélectionné';

  @override
  String get allocationMuscleCredit => 'Crédit musculaire';

  @override
  String get allocationBodypartCredit => 'Crédit par partie du corps';

  @override
  String get allocationNoTargetMuscles => 'Aucun muscle ciblé';

  @override
  String get allocationNoBodypartMapping => 'Aucune correspondance de partie du corps';

  @override
  String get allocationReset => 'Réinitialiser';

  @override
  String get allocationCredit => 'Crédit';

  @override
  String get allocationNoTargetMusclesBody => 'Cet exercice n’a pas encore de données de muscles ciblés.';

  @override
  String get allocationMuscleCreditBody => 'Modifiez une valeur pour créer une répartition personnelle. Elle est utilisée pour les résumés musculaires et le travail dérivé des parties du corps.';

  @override
  String get allocationNoBodypartMappingBody => 'Cet exercice n’a pas encore de données de correspondance de partie du corps.';

  @override
  String get allocationBodypartCreditBody => 'Les valeurs automatiques sont dérivées des muscles et de la correspondance anatomique. En modifier une crée une répartition personnelle directe par partie du corps.';

  @override
  String get healthTrendsTitle => 'Tendances santé';

  @override
  String get healthMetric => 'Mesure';

  @override
  String get healthUnableToLoad => 'Impossible de charger les mesures';

  @override
  String get healthNoMeasurements => 'Aucune mesure pour le moment';

  @override
  String get healthNoMeasurementsBody => 'Créez une mesure pour commencer à suivre vos progrès.';

  @override
  String get healthCreateMetric => 'Créer une mesure';

  @override
  String healthLogMeasurement(String name) {
    return 'Enregistrer $name';
  }

  @override
  String healthEditMeasurement(String name) {
    return 'Modifier $name';
  }

  @override
  String get healthTutorialSummaryTitle => 'Résumé de la mesure';

  @override
  String get healthTutorialSummaryBody => 'Voyez la dernière valeur, l’écart depuis l’entrée précédente et le nombre de relevés existants.';

  @override
  String get healthTutorialChartTitle => 'Graphique de tendance';

  @override
  String get healthTutorialChartBody => 'Le graphique montre l’évolution de cette mesure à mesure que vous ajoutez des entrées.';

  @override
  String get healthTutorialEntriesTitle => 'Entrées';

  @override
  String get healthTutorialEntriesBody => 'Touchez une entrée pour la modifier ou supprimez celles ajoutées par erreur.';

  @override
  String get healthTutorialLogTitle => 'Ajouter une entrée';

  @override
  String get healthTutorialLogBody => 'Utilisez ce bouton lorsque vous voulez ajouter un nouveau relevé.';

  @override
  String get healthDeleteEntryTitle => 'Supprimer l’entrée?';

  @override
  String healthDeleteEntryBody(String value, String date) {
    return 'La valeur $value du $date sera supprimée.';
  }

  @override
  String get healthLogEntry => 'Ajouter une entrée';

  @override
  String healthLoadFailed(String error) {
    return 'Impossible de charger : $error';
  }

  @override
  String get healthEntries => 'Entrées';

  @override
  String get healthNoEntries => 'Aucune entrée pour le moment';

  @override
  String healthFirstEntry(String name) {
    return 'Enregistrez votre première mesure de $name.';
  }

  @override
  String get workoutReportLoadFailed => 'Impossible de charger le rapport d’entraînement.';

  @override
  String get workoutReportTitle => 'Rapport d’entraînement';

  @override
  String get workoutReportAdditionalDetails => 'Détails supplémentaires';

  @override
  String get recommendedSetsEdit => 'Modifier les séries recommandées';

  @override
  String get recommendedSetsTitle => 'Séries recommandées';

  @override
  String get recommendedSetsMinimum => 'Minimum de séries recommandées';

  @override
  String get recommendedSetsMaximum => 'Maximum de séries recommandées';

  @override
  String get recommendedSetsValidNumbers => 'Entrez des nombres de séries valides.';

  @override
  String get recommendedSetsNonNegative => 'Le nombre de séries ne peut pas être négatif.';

  @override
  String get recommendedSetsRange => 'Le maximum doit être au moins égal au minimum.';

  @override
  String get workoutReportWorkouts => 'Entraînements';

  @override
  String get workoutReportTime => 'Temps';

  @override
  String get workoutReportVolume => 'Volume';

  @override
  String get workoutReportWorkout => 'entraînement';

  @override
  String get workoutReportTotal => 'total';

  @override
  String get databaseSettingsTitle => 'Réglages de la base de données';

  @override
  String get databaseSettingsSubtitle => 'Sauvegardes, médias infonuagiques, vérifications et exportations pour développeurs.';

  @override
  String get databaseBackupRestore => 'Sauvegarde et restauration';

  @override
  String get databaseBackupRestoreSubtitle => 'Importez ou exportez vos données Tonos locales en toute sécurité.';

  @override
  String get databaseExportBackup => 'Exporter une sauvegarde de la base de données';

  @override
  String get databaseImportBackup => 'Importer une sauvegarde de la base de données';

  @override
  String get databaseImportBackupSubtitle => 'Remplacez les données locales à partir d’un fichier d’exportation enregistré.';

  @override
  String get databaseHealth => 'État de santé';

  @override
  String get databaseHealthSubtitle => 'Un aperçu rapide de la taille, du schéma et de l’index de recherche.';

  @override
  String get databaseCheckingHealth => 'Vérification de l’état de la base de données...';

  @override
  String get databaseCheckingHealthSubtitle => 'Lecture du schéma, de la taille, des tables et des index.';

  @override
  String get databaseHealthFailed => 'Échec de la vérification de la base de données';

  @override
  String get databaseMaintenance => 'Entretien';

  @override
  String get databaseMaintenanceSubtitle => 'Outils sécuritaires de vérification, d’optimisation et de nettoyage du stockage.';

  @override
  String get databaseRefreshHealth => 'Actualiser l’état';

  @override
  String get databaseIntegrityCheck => 'Exécuter la vérification d’intégrité';

  @override
  String get databaseIntegrityCheckSubtitle => 'Demandez à SQLite de vérifier le fichier de base de données local.';

  @override
  String get databaseOptimize => 'Optimiser la base de données';

  @override
  String get databaseCheckpointWal => 'Point de contrôle WAL';

  @override
  String get databaseCheckpointWalSubtitle => 'Transfère le journal d’écriture anticipée dans le fichier de base de données.';

  @override
  String get databaseVacuum => 'Compacter la base de données';

  @override
  String get databaseVacuumSubtitle => 'Récupère l’espace libre après des suppressions ou importations importantes.';

  @override
  String get databaseCloudContent => 'Contenu infonuagique';

  @override
  String get databaseCloudContentSubtitle => 'Gérez le stockage des médias d’exercices, d’équipements et d’anatomie.';

  @override
  String get databaseWifiOnly => 'Téléchargements par Wi-Fi seulement';

  @override
  String get databaseWifiOnlySubtitle => 'Les nouvelles miniatures et vidéos se téléchargent seulement par Wi-Fi. Les médias en cache fonctionnent toujours hors ligne.';

  @override
  String get databaseSyncExerciseMedia => 'Synchroniser les médias d’exercices distants';

  @override
  String get databaseSyncSharedMedia => 'Synchroniser les médias du catalogue partagé';

  @override
  String get databaseSyncSharedMediaSubtitle => 'Illustrations d’équipement, de parties du corps et de muscles.';

  @override
  String get databaseClearMediaCache => 'Effacer le cache des médias téléchargés';

  @override
  String get databaseClearMediaCacheSubtitle => 'Supprime les fichiers média distants mis en cache sur cet appareil.';

  @override
  String get databaseDefinitionExports => 'Exportations de définitions';

  @override
  String get databaseDefinitionExportsSubtitle => 'Exportez les fichiers de définition de l’application pour inspection ou outils.';

  @override
  String get exerciseEditorTitle => 'Éditeur d’exercices';

  @override
  String get exerciseEditorLoadFailed => 'Impossible de charger les définitions d’exercices.';

  @override
  String get exerciseEditorChoose => 'Choisir un exercice';

  @override
  String get exerciseEditorEdit => 'Modifier la définition';

  @override
  String get exerciseEditorCreate => 'Créer un exercice personnalisé';

  @override
  String get exerciseEditorSaveChanges => 'Enregistrer les modifications';

  @override
  String get exerciseEditorSaving => 'Enregistrement';

  @override
  String get exerciseEditorMuscles => 'Muscles';

  @override
  String get exerciseEditorBodyparts => 'Parties du corps';

  @override
  String get exerciseEditorEquipment => 'Équipement';

  @override
  String get exerciseEditorGuide => 'Guide';

  @override
  String exerciseProgressAlreadyShown(String name) {
    return '$name est déjà affiché.';
  }

  @override
  String get exerciseProgressTrendTitle => 'Tendance du 1RM';

  @override
  String get exerciseProgressTrendBody => 'Ce graphique compare le 1RM réellement enregistré et le 1RM estimé au fil du temps. Touchez les points pour les valeurs exactes.';

  @override
  String get exerciseProgressRecordings => 'Enregistrements';

  @override
  String get exerciseProgressRecordingsBody => 'Chaque enregistrement ouvre l’entraînement où cette levée a eu lieu afin que vous puissiez consulter le contexte complet.';

  @override
  String get exerciseProgressTitle => 'Progrès du 1RM';

  @override
  String get exerciseProgressEmpty => 'Terminez cet exercice pour commencer à créer un historique de progrès.';

  @override
  String get exerciseProgressActual => '1RM réel';

  @override
  String get exerciseProgressEstimated => '1RM estimé';

  @override
  String get exerciseProgressSessionOpenFailed => 'Impossible d’ouvrir la séance d’entraînement.';

  @override
  String get exerciseProgressSessionMissing => 'Séance d’entraînement introuvable.';

  @override
  String exerciseProgressEstimatedValue(String value) {
    return 'Est. $value';
  }

  @override
  String get exerciseProgressNoActual => 'Aucun 1RM réel';

  @override
  String exerciseProgressActualValue(String value) {
    return 'Réel $value';
  }

  @override
  String get musclePercentTitle => '% sollicité par muscle';

  @override
  String musclePercentLoadFailed(String error) {
    return 'Échec du chargement des entrées : $error';
  }

  @override
  String musclePercentUpdateFailed(String error) {
    return 'Échec de la mise à jour du pourcentage : $error';
  }

  @override
  String musclePercentResetFailed(String error) {
    return 'Échec de la réinitialisation à la valeur par défaut : $error';
  }

  @override
  String musclePercentError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get musclePercentNoExercises => 'Aucun exercice défini';

  @override
  String get musclePercentEmpty => 'Aucun pourcentage musculaire défini';

  @override
  String get musclePercentLabel => '%';

  @override
  String get musclePercentRevert => 'Rétablir la valeur par défaut';

  @override
  String get sevenDayFocusTitle => 'Aperçu hebdomadaire';

  @override
  String get sevenDayFocusLoadFailed => 'Impossible de charger le travail des 7 derniers jours';

  @override
  String get sevenDayFocusEmpty => 'Aucune unité de série terminée par partie du corps au cours des 7 derniers jours.';

  @override
  String get sevenDayFocusMore => 'de plus';

  @override
  String get pastSessionsWeek => 'Semaine';

  @override
  String get pastSessionsMonth => 'Mois';

  @override
  String get pastSessionsYear => 'Année';

  @override
  String get pastSessionsAll => 'Tout';

  @override
  String get pastSessionsShow => 'Afficher :';

  @override
  String get pastSessionsFullscreen => 'Plein écran';

  @override
  String pastSessionsError(String error) {
    return 'Erreur : $error';
  }

  @override
  String get pastSessionsEmpty => 'Aucune séance pour le moment.';

  @override
  String pastSessionsItem(String date, int minutes) {
    return '$date - $minutes min';
  }

  @override
  String get historySummaryLoadFailed => 'Erreur lors du chargement de l’historique';

  @override
  String get historySummaryWorkouts => 'Entraînements';

  @override
  String get historySummaryTotalTime => 'Temps total';

  @override
  String get historySummaryTotalVolume => 'Volume total';

  @override
  String get planCoachSkipGuide => 'Passer le guide';

  @override
  String get planCoachContinue => 'Continuer';

  @override
  String get trainOptimizedSettingsTitle => 'Réglages d’entraînement optimisé';

  @override
  String get trainOptimizedSettingsBudgetBody => 'Utilise un budget de 3 minutes par série, plus 5 minutes pour commencer chaque exercice.';

  @override
  String get trainOptimizedSettingsFocusBody => 'Les choix de parties du corps s’appliquent seulement au prochain entraînement optimisé lancé.';

  @override
  String get trainWorkoutDuration => 'Durée de l’entraînement';

  @override
  String get trainMinutesShort => 'min';

  @override
  String get trainSetsPerExercise => 'Maximum de séries par exercice';

  @override
  String get trainSetsShort => 'séries';

  @override
  String get trainBodypartFocus => 'Priorité des parties du corps';

  @override
  String get trainBodypartFocusHelp => 'Touchez une fois pour préférer une partie du corps, encore une fois pour l’éviter, puis une troisième fois pour effacer.';

  @override
  String get trainBodypartsLoadFailed => 'Impossible de charger les parties du corps.';

  @override
  String get trainPlanGenerated => 'Plan généré. Ouverture en cours.';

  @override
  String trainPlansGenerated(int count) {
    return '$count plans générés.';
  }

  @override
  String get trainActiveWorkoutKept => 'Un autre entraînement est déjà actif; il a donc été conservé sans modification.';

  @override
  String get trainMenuTitle => 'Menu d’entraînement';

  @override
  String get trainExerciseCatalog => 'Catalogue d’exercices';

  @override
  String get trainMuscleFilter => 'Filtre musculaire';

  @override
  String get trainGymSettings => 'Réglages de gym et d’entraînement';

  @override
  String get trainTab => 'Entraînement';

  @override
  String get trainHistoryTab => 'Historique';

  @override
  String get trainExercisePresets => 'Plans d’exercices';

  @override
  String get trainGeneratePlans => 'Générer des plans personnalisés';

  @override
  String get trainAddPlan => 'Ajouter un plan manuellement';

  @override
  String get trainNewPlanFirst => 'Nouveau plan';

  @override
  String trainNewPlan(int number) {
    return 'Nouveau plan $number';
  }

  @override
  String get trainBuildingOptimized => 'Création de l’entraînement optimisé...';

  @override
  String get trainStartOptimized => 'Commencer l’entraînement optimisé';

  @override
  String get trainNewSession => 'Nouvelle séance';

  @override
  String get foodCustomizationTitle => 'Personnaliser l’aliment';

  @override
  String get foodCustomizationEditTitle => 'Modifier l’aliment';

  @override
  String get foodCustomizationName => 'Nom de l’aliment';

  @override
  String get foodCustomizationEnterName => 'Entrez un nom';

  @override
  String get foodCustomizationBrand => 'Marque';

  @override
  String get foodCustomizationFoodPhoto => 'Photo de l’aliment';

  @override
  String get foodCustomizationLabelPhoto => 'Photo de l’étiquette';

  @override
  String get foodCustomizationDensity => 'Densité (g/mL)';

  @override
  String get foodCustomizationDensityHelp => 'Utilisée pour convertir les portions en mL (tasses, c. à soupe) en grammes pour les calculs de macronutriments.';

  @override
  String get foodCustomizationCalories => 'Calories (kcal)';

  @override
  String get foodCustomizationMacronutrients => 'Macronutriments';

  @override
  String get foodCustomizationMicronutrients => 'Micronutriments';

  @override
  String get foodCustomizationAdditionalComponents => 'Composants supplémentaires';

  @override
  String get foodCustomizationPortionInfo => 'Informations sur la portion';

  @override
  String get foodCustomizationBasisPortion => 'Base de portion pour les valeurs nutritionnelles';

  @override
  String get foodCustomizationUsualPortion => 'Portion habituelle consommée par l’utilisateur';

  @override
  String get foodCustomizationAddPortion => 'Ajouter une portion';

  @override
  String get foodCustomizationUnit => 'Unité';

  @override
  String get foodCustomizationAmount => 'Quantité';

  @override
  String get foodCustomizationWeight => 'Poids (g)';

  @override
  String get foodCustomizationVolume => 'Volume (mL)';

  @override
  String get dashboardArchivedPlans => 'Plans archivés';

  @override
  String get dashboardActivePlans => 'Plans actifs';

  @override
  String get dashboardManagePlans => 'Gérer les plans';

  @override
  String get dashboardSelectProfilePlans => 'Sélectionnez un profil de salle pour voir ses plans.';

  @override
  String get dashboardNoArchivedPlans => 'Aucun plan archivé pour ce profil.';

  @override
  String get dashboardNoActivePlans => 'Aucun plan actif pour le moment. Utilisez le crayon pour choisir des plans.';

  @override
  String dashboardPremadeCount(int count) {
    return '$count routines prêtes à utiliser peuvent être ajoutées.';
  }

  @override
  String get dashboardBrowsePremadePlans => 'Parcourir les plans prédéfinis';

  @override
  String get dashboardNewPlanFirst => 'Nouveau plan';

  @override
  String dashboardNewPlan(int number) {
    return 'Nouveau plan $number';
  }

  @override
  String get dashboardPlanTools => 'Outils de planification';

  @override
  String get dashboardPlanToolsBody => 'Créez un plan à partir de vos préférences d’entraînement ou commencez-en un vide.';

  @override
  String get dashboardManual => 'Manuel';

  @override
  String get dashboardGenerate => 'Générer';

  @override
  String get dashboardMostUsedExercises => 'Exercices les plus utilisés';

  @override
  String get dashboardMostUsedExercisesEmpty => 'Terminez des entraînements pour voir ici vos exercices les plus fréquents.';

  @override
  String premadeDiscardFailed(String error) {
    return 'Impossible d’ignorer les plans ajoutés : $error';
  }

  @override
  String get premadeEquipmentSelectProfile => 'Sélectionnez un profil de salle pour adapter les plans à l’équipement disponible.';

  @override
  String get premadeEquipmentExact => 'Les plans prédéfinis sont affichés exactement tels qu’ils ont été écrits.';

  @override
  String get premadeEquipmentChecking => 'Vérification des exercices du plan avec votre profil...';

  @override
  String get premadeEquipmentMissing => 'Aucun équipement de profil n’a été trouvé; les plans prédéfinis restent donc inchangés.';

  @override
  String premadeEquipmentReplacements(int count) {
    return '$count exercice(s) indisponible(s) seront remplacés lors de l’ajout des plans.';
  }

  @override
  String get premadeEquipmentFits => 'Les plans conviennent déjà à l’équipement du profil actuel.';

  @override
  String get premadeOneHour => '1 h';

  @override
  String get premadeTwoHours => '2 h';

  @override
  String premadePlansAvailable(int count) {
    return '$count plan(s) disponible(s)';
  }

  @override
  String get premadeNoTemplates => 'Aucun modèle de plan pour le moment';

  @override
  String premadePlansCount(int count) {
    return '$count plan(s)';
  }

  @override
  String get premadeTemplatesLater => 'Des modèles pour cette répartition pourront être ajoutés ici plus tard.';

  @override
  String premadeExerciseCount(int count) {
    return '$count exercices';
  }

  @override
  String premadeSetCount(int count) {
    return '$count séries';
  }

  @override
  String premadeSwappedCount(int count) {
    return '$count remplacés';
  }

  @override
  String get premadeAdding => 'Ajout';

  @override
  String get premadeChecking => 'Vérification';

  @override
  String get premadeProfileSwap => 'remplacement selon le profil';

  @override
  String get healthEntryValueUnitRequired => 'Entrez d’abord une valeur et une unité.';

  @override
  String get healthDefinitionFieldsRequired => 'Entrez un nom, une unité et une valeur valide.';

  @override
  String get healthUnit => 'Unité';

  @override
  String get healthNote => 'Note';

  @override
  String get healthOptional => 'Facultatif';

  @override
  String get healthMetricName => 'Nom de la mesure';

  @override
  String get healthMetricNameHint => 'Tour de bras, fréquence cardiaque au repos...';

  @override
  String healthUnitHint(String weightUnit) {
    return 'po, $weightUnit, %, bpm...';
  }

  @override
  String get healthStartingValue => 'Valeur de départ';

  @override
  String get healthCreate => 'Créer';

  @override
  String get exerciseProgressNoRecordings => 'Aucun enregistrement pour le moment';

  @override
  String get exerciseEditorDiscardTitle => 'Ignorer les modifications?';

  @override
  String get exerciseEditorDiscardBody => 'Vos modifications ne sont pas encore enregistrées. Vous pouvez continuer ou les ignorer.';

  @override
  String get exerciseEditorKeepEditing => 'Continuer la modification';

  @override
  String get exerciseEditorDiscard => 'Ignorer';

  @override
  String get exerciseEditorAddBodyparts => 'Ajouter des parties du corps associées';

  @override
  String get exerciseEditorAddMuscles => 'Ajouter des muscles associés';

  @override
  String get exerciseEditorAddEquipment => 'Ajouter de l’équipement';

  @override
  String get databaseClearMediaTitle => 'Effacer les médias téléchargés?';

  @override
  String get databaseClearMediaBody => 'Cette action supprime les médias d’exercices, d’équipements et d’anatomie mis en cache. L’application pourra les télécharger de nouveau au besoin.';

  @override
  String get databaseClearCache => 'Effacer le cache';

  @override
  String get databaseCacheCleared => 'Le cache des médias téléchargés a été effacé.';

  @override
  String databaseClearCacheFailed(String error) {
    return 'Échec de l’effacement du cache : $error';
  }

  @override
  String get databaseContentEnvironment => 'Environnement de contenu';

  @override
  String get databaseLoadingEnvironment => 'Chargement de l’environnement...';

  @override
  String get databaseChangeEnvironment => 'Changer d’environnement';

  @override
  String get databaseExerciseManifestUrl => 'URL du manifeste de médias d’exercices';

  @override
  String get databaseNoExerciseManifestUrl => 'Aucune URL de manifeste distant n’est définie pour cet environnement.';

  @override
  String get databaseOverrideUrl => 'URL de remplacement';

  @override
  String get databaseNoManifestSynced => 'Aucun manifeste synchronisé';

  @override
  String databaseManifestVersion(int version) {
    return 'Manifeste v$version';
  }

  @override
  String databaseLastChecked(String date) {
    return 'Dernière vérification : $date';
  }

  @override
  String get databaseSharedCatalogMedia => 'Médias du catalogue partagé';

  @override
  String get databaseSharedMediaNotSynced => 'Pas encore synchronisé. Équipement, parties du corps et muscles.';

  @override
  String databaseManifestLastChecked(int version, String date) {
    return 'Manifeste v$version. Dernière vérification : $date';
  }

  @override
  String get databaseSharedManifestUrl => 'URL du manifeste de médias partagés';

  @override
  String get databaseNoSharedManifestUrl => 'Aucune URL de médias partagés distants n’est définie pour cet environnement.';

  @override
  String get databaseDownloadedMediaCache => 'Cache des médias téléchargés';

  @override
  String databaseCacheUsage(int count, String size) {
    return '$count fichiers, $size';
  }

  @override
  String get databaseLoadBundledManifest => 'Charger le manifeste inclus';

  @override
  String get databaseTutorialFilesTitle => 'Fichiers de base de données';

  @override
  String get databaseTutorialFilesBody => 'Exportez une sauvegarde ou importez un fichier de base de données enregistré. Les importations exigent d’abord une sauvegarde.';

  @override
  String get databaseTutorialHealthTitle => 'État de la base de données';

  @override
  String get databaseTutorialHealthBody => 'Cette carte montre la version du schéma, la taille de la base de données, le nombre de tables et l’état de l’index de recherche.';

  @override
  String get databaseTutorialMaintenanceTitle => 'Outils d’entretien';

  @override
  String get databaseTutorialMaintenanceBody => 'Utilisez ces actions pour les vérifications d’intégrité, l’optimisation, le point de contrôle WAL ou le compactage au besoin.';

  @override
  String get databaseExportSavedTitle => 'Exportation de la base de données enregistrée';

  @override
  String get databaseExportSavedBody => 'L’exportation de la base de données a été enregistrée à l’emplacement sélectionné.';

  @override
  String databaseImportBlocked(String message) {
    return 'Importation bloquée : $message';
  }

  @override
  String get databaseImportBackupCanceled => 'Importation annulée : la sauvegarde n’a pas été enregistrée.';

  @override
  String get databaseImportSucceededTitle => 'Importation réussie';

  @override
  String databaseImportSucceededBody(String name) {
    return '$name a été importé. Une sauvegarde de la base de données locale précédente a d’abord été enregistrée à l’emplacement sélectionné.';
  }

  @override
  String get databaseConfirmImportTitle => 'Confirmer l’importation';

  @override
  String get databaseConfirmImportBody => 'Cette action remplace la base de données locale. Une sauvegarde de la base de données actuelle sera créée d’abord.';

  @override
  String databaseImportFile(String name) {
    return 'Fichier : $name';
  }

  @override
  String databaseImportTables(int count) {
    return 'Tables : $count';
  }

  @override
  String databaseImportRows(int count) {
    return 'Lignes : $count';
  }

  @override
  String databaseImportSchema(int version) {
    return 'Schéma d’exportation : v$version';
  }

  @override
  String get databaseImportLegacyFormat => 'Format : ancienne table de correspondance';

  @override
  String get databaseImportWarnings => 'Avertissements :';

  @override
  String get databaseBackupAndImport => 'Sauvegarder et importer';

  @override
  String databaseMaintenanceFailed(String error) {
    return 'Échec de l’entretien de la base de données : $error';
  }

  @override
  String get exerciseEditorSaveBeforeAllocation => 'Enregistrez ou annulez les modifications de définition avant de modifier le crédit par série.';

  @override
  String exerciseEditorRemoveItemTitle(String type) {
    return 'Retirer $type?';
  }

  @override
  String exerciseEditorRemoveItemBody(String name) {
    return 'Retirer « $name » de cette définition d’exercice?';
  }

  @override
  String get exerciseEditorKeep => 'Conserver';

  @override
  String get exerciseEditorMuscleOrderTitle => 'Ordre des muscles ciblés';

  @override
  String get exerciseEditorMuscleOrderBody => 'Classez les muscles selon l’intensité avec laquelle l’exercice les cible. Cela aide Tonos à estimer le travail anatomique et à recommander de meilleurs exercices.';

  @override
  String get exerciseEditorExactSetCredit => 'Crédit exact par série';

  @override
  String get exerciseEditorExactSetCreditBody => 'Modifiez le crédit précis qu’une série accorde à chaque muscle ou partie du corps dans Répartition des séries par exercice.';

  @override
  String get exerciseEditorSetCreditScaling => 'Mise à l’échelle du crédit par série';

  @override
  String get exerciseEditorSetCreditScalingBody => 'Choisissez si la note de cet exercice doit mettre à l’échelle le crédit par série.';

  @override
  String get exerciseEditorScaleCreditByRating => 'Mettre le crédit à l’échelle selon la note';

  @override
  String get exerciseEditorScaleCreditByRatingBody => 'Applique la note de l’exercice aux totaux de séries analytiques.';

  @override
  String get exerciseEditorTargetMuscles => 'Muscles ciblés';

  @override
  String get exerciseEditorOrderMusclesHint => 'Utilisez les flèches pour ordonner les muscles selon l’accent ciblé.';

  @override
  String exerciseEditorMusclesAssociated(int count) {
    return '$count muscles sont actuellement associés.';
  }

  @override
  String get exerciseEditorNoTargetMuscles => 'Aucun muscle ciblé n’est encore associé.';

  @override
  String get exerciseEditorAddTargetMuscles => 'Ajouter des muscles ciblés';

  @override
  String get exerciseEditorMoveUp => 'Monter';

  @override
  String get exerciseEditorMoveDown => 'Descendre';

  @override
  String get exerciseEditorRemoveMuscle => 'Retirer le muscle';

  @override
  String get exerciseEditorMuscleItem => 'muscle';

  @override
  String get exerciseEditorAssociatedBodyparts => 'Parties du corps associées';

  @override
  String get exerciseEditorAssociatedBodypartsBody => 'Ces zones générales servent aux cartes thermiques, à la couverture hebdomadaire et aux recommandations d’entraînement tenant compte de l’équipement.';

  @override
  String get exerciseEditorExactBodypartCredit => 'Crédit exact par partie du corps';

  @override
  String get exerciseEditorExactBodypartCreditBody => 'Utilisez Répartition des séries par exercice lorsqu’une série doit compter comme une portion précise pour une partie du corps.';

  @override
  String get exerciseEditorBodypartsHint => 'Ajoutez chaque zone corporelle générale travaillée par cet exercice.';

  @override
  String exerciseEditorBodypartsAssociated(int count) {
    return '$count parties du corps sont actuellement associées.';
  }

  @override
  String get exerciseEditorNoBodyparts => 'Aucune partie du corps n’est encore associée.';

  @override
  String get exerciseEditorAutomaticPreview => 'Aperçu automatique';

  @override
  String get exerciseEditorAutomaticPreviewBody => 'Travail actuel dérivé de la structure des muscles ciblés.';

  @override
  String get exerciseEditorRemoveBodypart => 'Retirer la partie du corps';

  @override
  String get exerciseEditorBodypartItem => 'partie du corps';

  @override
  String get exerciseEditorAvailableEquipment => 'Équipement disponible';

  @override
  String get exerciseEditorAvailableEquipmentBody => 'L’équipement associé détermine quels profils peuvent utiliser cet exercice et quels remplacements Tonos peut recommander.';

  @override
  String get exerciseEditorEquipmentHint => 'Ajoutez chaque élément nécessaire pour exécuter cet exercice.';

  @override
  String exerciseEditorEquipmentAssociated(int count) {
    return '$count éléments sont associés.';
  }

  @override
  String get exerciseEditorNoEquipment => 'Aucun équipement n’est encore associé.';

  @override
  String get exerciseEditorRemoveEquipment => 'Retirer l’équipement';

  @override
  String get exerciseEditorEquipmentItem => 'équipement';

  @override
  String get historySummaryAll => 'Tout';

  @override
  String historySummaryDuration(int hours, int minutes) {
    return '$hours h $minutes min';
  }

  @override
  String planCoachStepTitle(int step, int total, String title) {
    return '$step/$total - $title';
  }

  @override
  String get databaseManifestUrlRequired => 'Ajoutez d’abord une URL de manifeste de médias d’exercices valide.';

  @override
  String databaseContentSyncFailed(String error) {
    return 'Échec de la synchronisation du contenu : $error';
  }

  @override
  String databaseBundledContentSyncFailed(String error) {
    return 'Échec de la synchronisation du contenu inclus : $error';
  }

  @override
  String get databaseSharedMediaUrlMissing => 'Cet environnement de contenu n’a aucune URL de médias partagés.';

  @override
  String databaseSharedContentSyncFailed(String error) {
    return 'Échec de la synchronisation du contenu partagé : $error';
  }

  @override
  String databaseDefinitionExportFailed(String filename, String error) {
    return 'Échec de l’exportation de $filename : $error';
  }

  @override
  String get databaseExerciseManifestDialogTitle => 'Manifeste de médias d’exercices';

  @override
  String get databaseManifestUrl => 'URL du manifeste';

  @override
  String get databaseClear => 'Effacer';

  @override
  String get databaseNoManifestConfigured => 'Aucune URL de manifeste n’est encore configurée.';

  @override
  String get databaseUseEnvironment => 'Utiliser l’environnement';

  @override
  String get dashboardTargetAnatomy => 'Anatomie ciblée';

  @override
  String get dashboardBodyparts => 'Parties du corps';

  @override
  String get dashboardMuscles => 'Muscles';

  @override
  String get exerciseEditorCreateCustomTitle => 'Créer un exercice personnalisé';

  @override
  String get exerciseEditorCreateCustomBody => 'Créez une définition de catalogue personnalisée, puis ajoutez son anatomie ciblée et ses consignes avant d’enregistrer.';

  @override
  String get exerciseEditorExerciseName => 'Nom de l’exercice';

  @override
  String get exerciseEditorNoEquipmentChoice => 'Aucun équipement';

  @override
  String get exerciseEditorOpenedMessage => 'Exercice ouvert. Ajoutez son anatomie ciblée, puis enregistrez.';

  @override
  String exerciseEditorCreateFailed(String error) {
    return 'Impossible de créer l’exercice personnalisé. $error';
  }

  @override
  String get exerciseEditorWhatChangesTitle => 'Ce qui change';

  @override
  String get exerciseEditorWhatChangesBody => 'Utilisez cet éditeur avancé pour modifier le nom d’un exercice, son anatomie ciblée, son équipement, ses consignes de forme, sa note et ses médias de référence. Le crédit exact par série est géré séparément pour rester cohérent dans toute l’application.';

  @override
  String get exerciseEditorChooseCatalog => 'Choisir un exercice dans le catalogue';

  @override
  String get exerciseEditorRating => 'Note';

  @override
  String get databaseNever => 'Jamais';

  @override
  String databaseExportDefinition(String filename) {
    return 'Exporter $filename';
  }

  @override
  String get exerciseEditorAddMedia => 'Ajouter un média';

  @override
  String get exerciseEditorEditMedia => 'Modifier le média';

  @override
  String get exerciseEditorMediaImage => 'Image';

  @override
  String get exerciseEditorMediaVideo => 'Vidéo';

  @override
  String get exerciseEditorMediaLink => 'Lien';

  @override
  String get exerciseEditorMediaType => 'Type';

  @override
  String get exerciseEditorMediaTitle => 'Titre';

  @override
  String get exerciseEditorMediaTitleHint => 'Libellé d’affichage facultatif';

  @override
  String get exerciseEditorMediaRemoteUrl => 'URL distante';

  @override
  String get exerciseEditorMediaThumbnailUrl => 'URL de miniature';

  @override
  String get exerciseEditorMediaThumbnailHint => 'URL facultative d’aperçu d’image';

  @override
  String get exerciseEditorSelectBeforeMedia => 'Sélectionnez un exercice existant avant d’y associer un média.';

  @override
  String get exerciseEditorFormGuide => 'Guide de forme';

  @override
  String get exerciseEditorFormGuideBody => 'Ces notes apparaissent dans la fiche de détails de l’exercice pour aider les utilisateurs à s’installer, effectuer et comprendre le mouvement en sécurité.';

  @override
  String get exerciseEditorGuidance => 'Consignes';

  @override
  String get exerciseEditorGuidanceEditing => 'Rédigez des indications claires et pratiques. Les modifications restent en attente jusqu’à leur enregistrement.';

  @override
  String get exerciseEditorGuidanceReadOnly => 'Les instructions et indications actuelles de l’exercice.';

  @override
  String get exerciseEditorSetUp => 'Mise en place';

  @override
  String get exerciseEditorSetUpHint => 'Position de départ, installation de l’équipement et notes de sécurité.';

  @override
  String get exerciseEditorHowToPerform => 'Comment effectuer';

  @override
  String get exerciseEditorHowToPerformHint => 'Les étapes clés du mouvement et l’amplitude.';

  @override
  String get exerciseEditorCoachingTips => 'Conseils d’entraînement';

  @override
  String get exerciseEditorCoachingTipsHint => 'Indications utiles, erreurs fréquentes et variantes.';

  @override
  String get exerciseEditorReferenceMedia => 'Médias de référence';

  @override
  String get exerciseEditorReferenceMediaBody => 'Utilisez les liens média pour du matériel de référence privé. Les médias du catalogue géré peuvent être actualisés par le pipeline de synchronisation de contenu.';

  @override
  String get exerciseEditorMediaLinks => 'Liens média';

  @override
  String get exerciseEditorMediaLinksEditing => 'Ajoutez ou mettez à jour une image, une vidéo ou un lien de référence distant.';

  @override
  String exerciseEditorMediaLinksCount(int count) {
    return '$count élément(s) média sont actuellement associés.';
  }

  @override
  String get exerciseEditorNoReferenceMedia => 'Aucun média de référence n’est encore associé.';

  @override
  String get exerciseEditorAddMediaLink => 'Ajouter un lien média';

  @override
  String get exerciseEditorRemoveMedia => 'Retirer le média';

  @override
  String get exerciseEditorMediaLinkItem => 'lien média';

  @override
  String exerciseEditorMediaReference(String type) {
    return 'référence $type';
  }

  @override
  String get bengaliBangladeshLanguage => 'Bengali (Bangladesh)';

  @override
  String get simplifiedChineseLanguage => 'Chinois simplifié';

  @override
  String get hindiLanguage => 'Hindi';

  @override
  String get spanishLanguage => 'Espagnol';

  @override
  String get onboardingWeightHistoryTitle => 'Historique du poids';

  @override
  String get onboardingWeightHistorySubtitle => 'Quelques détails permettent d’estimer les objectifs nutritionnels plus judicieusement.';

  @override
  String get onboardingPreviouslyHeavier => 'Avez-vous déjà pesé au moins 10 lb de plus que votre poids actuel?';

  @override
  String get onboardingWeightTrendTitle => 'Tendance actuelle du poids';

  @override
  String get onboardingWeightTrendGaining => 'Prise de poids';

  @override
  String get onboardingWeightTrendLosing => 'Perte de poids';

  @override
  String get onboardingWeightTrendMaintaining => 'Maintien du poids';

  @override
  String get onboardingNotSure => 'Je ne sais pas';

  @override
  String get onboardingBodyFatEstimateTitle => 'Estimation du taux de graisse';

  @override
  String get onboardingBodyFatEstimateSubtitle => 'Choisissez l’estimation visuelle la plus proche. Une grande précision n’est pas nécessaire.';

  @override
  String get onboardingNutritionPreferencesTitle => 'Préférences nutritionnelles';

  @override
  String get onboardingNutritionPreferencesSubtitle => 'Ces préférences orientent les suggestions nutritionnelles après la configuration.';

  @override
  String get onboardingPreferredDiet => 'Régime préféré';

  @override
  String get onboardingDietBalanced => 'Équilibré';

  @override
  String get onboardingDietLowFat => 'Faible en gras';

  @override
  String get onboardingDietLowCarb => 'Faible en glucides';

  @override
  String get onboardingDietKeto => 'Cétogène';

  @override
  String get onboardingCalorieFloor => 'Minimum calorique';

  @override
  String get onboardingCalorieFloorHint => 'Minimum quotidien en kcal';

  @override
  String get onboardingTrainingDuringProgram => 'Entraînement pendant le programme';

  @override
  String get onboardingTrainingNone => 'Aucun';

  @override
  String get onboardingTrainingLifting => 'Musculation';

  @override
  String get onboardingTrainingCardio => 'Cardio';

  @override
  String get onboardingTrainingLiftingAndCardio => 'Musculation et cardio';

  @override
  String get onboardingProteinPreference => 'Apport en protéines préféré';

  @override
  String get onboardingProteinLow => 'Faible';

  @override
  String get onboardingProteinModerate => 'Modéré';

  @override
  String get onboardingProteinHigh => 'Élevé';

  @override
  String get onboardingProteinVeryHigh => 'Très élevé';

  @override
  String get onboardingGoalPaceTitle => 'Rythme de l’objectif';

  @override
  String get onboardingGoalPaceSubtitle => 'Prévisualisez un poids cible et un rythme hebdomadaire.';

  @override
  String get onboardingInitialDailyBudget => 'Budget quotidien initial';

  @override
  String get onboardingProjectedEndDate => 'Date de fin prévue';

  @override
  String get onboardingTargetWeight => 'Poids cible';

  @override
  String get onboardingTargetGoalRate => 'Rythme cible';

  @override
  String get onboardingPerWeek => 'Par semaine';

  @override
  String get onboardingPerMonth => 'Par mois';

  @override
  String get exerciseProgressTrackExercise => 'Suivre un exercice';

  @override
  String get exerciseProgressTrackExerciseBody => 'Choisissez un exercice pour suivre ici la tendance de son 1RM.';

  @override
  String get healthCustomMetric => 'Mesure personnalisée';

  @override
  String get healthLatest => 'Dernière';

  @override
  String get healthNoEntry => 'Aucune donnée';

  @override
  String get healthNotTrackedYet => 'Pas encore suivie';

  @override
  String get healthChange => 'Variation';

  @override
  String get healthNeedTwoEntries => '2 données requises';

  @override
  String get healthVersusPrevious => 'Par rapport à la précédente';

  @override
  String get healthRecords => 'Données';

  @override
  String get presetEstimatedTime => 'Durée estimée';

  @override
  String get presetNoFocusData => 'Aucune donnée de ciblage.';

  @override
  String get presetFocusPreviewHelp => 'Ajoutez des exercices de musculation avec des données anatomiques pour prévisualiser le ciblage du plan.';

  @override
  String get dashboardReorderHelp => 'Faites glisser les sections dans l’ordre qui vous convient.';

  @override
  String get exerciseEditorCachedLocally => 'En cache local';

  @override
  String databaseExerciseMediaSyncSuccess(int count, int version) {
    return '$count médias d’exercice synchronisés (v$version).';
  }

  @override
  String databaseBundledManifestLoaded(int version) {
    return 'Manifeste de médias d’exercice intégré chargé (v$version).';
  }

  @override
  String databaseSharedMediaSyncSuccess(int count, int version) {
    return '$count médias d’équipement et d’anatomie synchronisés (v$version).';
  }

  @override
  String get databaseHealthSchema => 'Schéma';

  @override
  String databaseHealthSchemaValue(int current, int target) {
    return 'v$current / cible v$target';
  }

  @override
  String get databaseHealthSize => 'Taille';

  @override
  String get databaseHealthJournal => 'Journal';

  @override
  String get databaseHealthTables => 'Tables';

  @override
  String databaseHealthTablesValue(int tables, int indexes, int triggers) {
    return '$tables tables, $indexes index, $triggers déclencheurs';
  }

  @override
  String get databaseHealthFoodSearch => 'Recherche d’aliments';

  @override
  String databaseHealthFoodSearchValue(int foods, int rows) {
    return '$foods aliments, $rows lignes FTS';
  }

  @override
  String get databaseHealthPath => 'Chemin';

  @override
  String get dashboardWorkoutInProgress => 'Entraînement en cours';

  @override
  String get dashboardNoSavedPlans => 'Aucun plan enregistré pour ce profil de salle.';

  @override
  String get exerciseProgressOneRepMax => 'Maximum sur 1 répétition';

  @override
  String get exerciseProgressEstimatedOneRepMax => '1RM estimé';

  @override
  String get onboardingPageWeight => 'Poids';

  @override
  String get onboardingPageBodyFat => 'Graisse corporelle';

  @override
  String get onboardingPageNutrition => 'Nutrition';

  @override
  String get onboardingPageGoal => 'Objectif';

  @override
  String dashboardRecordsThisWeek(int count, int total) {
    return '$count/$total cette semaine';
  }

  @override
  String dashboardRecordsAllTime(int count) {
    return '$count au total';
  }

  @override
  String get dashboardVisualBodyFat => 'Graisse corporelle visuelle';

  @override
  String get dashboardNewMetric => 'Nouvelle mesure';

  @override
  String get dashboardCurrentMetrics => 'Mesures actuelles';

  @override
  String get workoutReportDay => 'jour';

  @override
  String get workoutReportDays => 'jours';

  @override
  String get workoutReportWeek => 'semaine';

  @override
  String get workoutReportMonth => 'mois';

  @override
  String workoutReportAveragePer(String period) {
    return 'Moy. / $period';
  }

  @override
  String get workoutReportWorkoutsLowercase => 'entraînements';

  @override
  String get workoutReportLongestStreak => 'Plus longue série';

  @override
  String get workoutReportMostActive => 'Plus actif';

  @override
  String get workoutReportNoSessions => 'aucune séance';

  @override
  String get workoutReportWeekday => 'jour de la semaine';

  @override
  String workoutReportMetricSemantics(String label) {
    return 'Mesure de rapport : $label';
  }

  @override
  String workoutReportUnitLogged(String unit) {
    return '$unit enregistrées';
  }

  @override
  String workoutReportUnitOnDate(String unit, String date) {
    return '$unit le $date';
  }

  @override
  String get profileDiagnosticsTitle => 'Diagnostics et confidentialité';

  @override
  String get profileDiagnosticsSubtitle => 'Version, consentement aux rapports, historique de synchronisation et suppression des données.';

  @override
  String get diagnosticsTitle => 'Diagnostics et confidentialité';

  @override
  String get diagnosticsSubtitle => 'Comprenez et contrôlez les diagnostics de production.';

  @override
  String get diagnosticsAppSection => 'Informations sur l’application';

  @override
  String get diagnosticsAppSectionSubtitle => 'Utiles lorsque vous signalez un problème.';

  @override
  String get diagnosticsVersion => 'Version et build';

  @override
  String get diagnosticsLoading => 'Chargement...';

  @override
  String get diagnosticsUnavailable => 'Non disponible';

  @override
  String get diagnosticsCrashSection => 'Rapports de plantage';

  @override
  String get diagnosticsCrashSectionSubtitle => 'Rapports facultatifs et expurgés sur les défaillances inattendues.';

  @override
  String get diagnosticsCrashReporting => 'Partager les rapports de plantage';

  @override
  String get diagnosticsCrashUnavailable => 'Non configuré dans cette version. Aucun rapport ne peut être envoyé.';

  @override
  String get diagnosticsCrashEnabledBody => 'Activé avec votre consentement. Vous pouvez le désactiver en tout temps.';

  @override
  String get diagnosticsCrashDisabledBody => 'Désactivé par défaut. Activez-le seulement pour aider à diagnostiquer les plantages.';

  @override
  String get diagnosticsPrivacyPromiseTitle => 'Confidentialité dès la conception';

  @override
  String get diagnosticsPrivacyPromiseBody => 'Les rapports contiennent la version de l’application, le contexte de la plateforme, un type d’erreur expurgé et la pile d’appels. Tonos exclut les noms, données de santé, contenus de base de données, captures d’écran, hiérarchie des vues, adresses réseau, traces de performance et analyses.';

  @override
  String get diagnosticsSyncSection => 'Historique de synchronisation';

  @override
  String get diagnosticsSyncSectionSubtitle => 'Les 30 derniers résultats des manifestes multimédias restent uniquement sur cet appareil.';

  @override
  String get diagnosticsNoSyncEvents => 'Aucun diagnostic de synchronisation';

  @override
  String get diagnosticsNoSyncEventsBody => 'Les résultats apparaîtront ici sans URL ni données personnelles.';

  @override
  String get diagnosticsClearHistory => 'Effacer l’historique';

  @override
  String get diagnosticsClearHistoryBody => 'Supprimer tous les diagnostics de synchronisation locaux.';

  @override
  String get diagnosticsHistoryCleared => 'Historique des diagnostics effacé.';

  @override
  String get diagnosticsExerciseMedia => 'Médias d’exercices';

  @override
  String get diagnosticsSharedMedia => 'Médias partagés';

  @override
  String get diagnosticsRemoteSource => 'À distance';

  @override
  String get diagnosticsBundledSource => 'Intégré';

  @override
  String get diagnosticsSyncSucceeded => 'Réussi';

  @override
  String get diagnosticsSyncFailed => 'Échec';

  @override
  String diagnosticsSyncEventTitle(String operation, String outcome) {
    return '$operation : $outcome';
  }

  @override
  String diagnosticsSyncEventDetails(String source, String timestamp, int duration, String version, String items) {
    return '$source • $timestamp • $duration ms • manifeste $version • $items éléments';
  }

  @override
  String get diagnosticsPrivacySection => 'Vos données';

  @override
  String get diagnosticsPrivacySectionSubtitle => 'Stockage local, conservation et suppression.';

  @override
  String get diagnosticsLocalDataTitle => 'Les données de mise en forme restent locales';

  @override
  String get diagnosticsLocalDataBody => 'Les entraînements, données nutritionnelles, mesures corporelles et profils restent dans la base de données de cet appareil, sauf si vous exportez vous-même une sauvegarde.';

  @override
  String get diagnosticsDeletionTitle => 'Supprimer les diagnostics et les données';

  @override
  String get diagnosticsDeletionBody => 'Effacez l’historique ci-dessus et désactivez les rapports. Effacez le stockage de Tonos dans les réglages de l’appareil ou désinstallez l’application pour supprimer la base locale et les caches. Pour supprimer un rapport déjà envoyé, communiquez avec le développeur en fournissant les détails de l’événement dont vous disposez.';
}
