import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case_model.dart';
import '../utils/constants.dart';

class SampleDataService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> seedSampleCases() async {
    try {
      // Check if cases already exist
      QuerySnapshot existingCases = await _firestore
          .collection(AppConstants.casesCollection)
          .limit(1)
          .get();

      if (existingCases.docs.isNotEmpty) {
        print('Sample cases already exist');
        return;
      }

      WriteBatch batch = _firestore.batch();

      // Sample Medicine Cases
      List<CaseModel> medicineCases = [
        CaseModel(
          id: 'med_case_01',
          departmentId: 'medicine',
          title: 'Chest Pain in a 45-year-old Male',
          scenario: '''
Mr. John Smith, a 45-year-old accountant, presents to the emergency department with a 2-hour history of severe central chest pain. The pain started suddenly while he was at work and is described as crushing and radiating to his left arm and jaw. He appears sweaty and anxious. He has a history of hypertension and is a smoker with a 20 pack-year history.

The patient is requesting immediate attention and appears to be in significant distress.
          ''',
          clerkingChecklist: {
            'biodata': ['age', 'sex', 'occupation', 'marital_status'],
            'presentingComplaint': ['chest_pain', 'duration', 'severity'],
            'HPC': [
              'onset',
              'character',
              'radiation',
              'aggravating_factors',
              'relieving_factors',
              'associated_symptoms'
            ],
            'reviewOfSystems': [
              'cardiovascular',
              'respiratory',
              'gastrointestinal',
              'neurological'
            ],
            'PMH': ['hypertension', 'diabetes', 'previous_mi', 'surgeries'],
            'FSH': [
              'family_history_cvd',
              'smoking_history',
              'alcohol_consumption',
              'exercise_habits'
            ],
          },
          followUpQuestions: [
            FollowUpQuestion(
              type: 'short_answer',
              question: 'What is your most likely diagnosis?',
            ),
            FollowUpQuestion(
              type: 'list',
              question: 'List 3 differential diagnoses',
            ),
            FollowUpQuestion(
              type: 'short_answer',
              question: 'What is the most urgent investigation you would order?',
            ),
            FollowUpQuestion(
              type: 'list',
              question: 'What immediate management steps would you take?',
            ),
          ],
          answers: {
            'diagnosis': 'ST-elevation myocardial infarction (STEMI)',
            'differentials': ['Unstable angina', 'Pulmonary embolism', 'Aortic dissection'],
            'investigation': '12-lead ECG',
            'management': ['Oxygen', 'Aspirin', 'Morphine', 'GTN', 'Call cardiology']
          },
          maxScore: 24,
        ),
        
        CaseModel(
          id: 'med_case_02',
          departmentId: 'medicine',
          title: 'Shortness of Breath in Elderly Woman',
          scenario: '''
Mrs. Margaret Johnson, a 72-year-old retired teacher, presents with a 3-day history of progressively worsening shortness of breath and ankle swelling. She reports difficulty sleeping and needs to use 3 pillows to sleep comfortably. She has a history of atrial fibrillation and takes warfarin. On examination, she appears tired and has bilateral ankle edema.

She mentions that she has been feeling more tired than usual over the past few weeks.
          ''',
          clerkingChecklist: {
            'biodata': ['age', 'sex', 'occupation', 'living_situation'],
            'presentingComplaint': ['shortness_of_breath', 'ankle_swelling', 'duration'],
            'HPC': [
              'onset',
              'progression',
              'orthopnea',
              'paroxysmal_nocturnal_dyspnea',
              'exercise_tolerance',
              'chest_pain'
            ],
            'reviewOfSystems': [
              'cardiovascular',
              'respiratory',
              'gastrointestinal',
              'weight_changes'
            ],
            'PMH': ['atrial_fibrillation', 'hypertension', 'heart_failure', 'medications'],
            'FSH': ['family_history', 'smoking', 'alcohol', 'social_support'],
          },
          followUpQuestions: [
            FollowUpQuestion(
              type: 'short_answer',
              question: 'What is your most likely diagnosis?',
            ),
            FollowUpQuestion(
              type: 'list',
              question: 'What investigations would you order?',
            ),
            FollowUpQuestion(
              type: 'short_answer',
              question: 'What class of medication would be most appropriate for immediate treatment?',
            ),
          ],
          answers: {
            'diagnosis': 'Acute exacerbation of heart failure',
            'investigations': ['Chest X-ray', 'ECG', 'BNP/NT-proBNP', 'FBC', 'U&E'],
            'medication': 'Diuretics (furosemide)'
          },
          maxScore: 21,
        ),
      ];

      // Sample Surgery Cases
      List<CaseModel> surgeryCases = [
        CaseModel(
          id: 'surg_case_01',
          departmentId: 'surgery',
          title: 'Acute Abdominal Pain',
          scenario: '''
Mr. David Williams, a 28-year-old construction worker, presents to the emergency department with a 6-hour history of severe abdominal pain. The pain started around his umbilicus and has now moved to the right lower quadrant. He has vomited twice and reports loss of appetite. He appears uncomfortable and is guarding his abdomen.

His temperature is 38.2°C and he looks unwell.
          ''',
          clerkingChecklist: {
            'biodata': ['age', 'sex', 'occupation'],
            'presentingComplaint': ['abdominal_pain', 'location', 'duration'],
            'HPC': [
              'pain_onset',
              'pain_character',
              'pain_migration',
              'nausea_vomiting',
              'bowel_movements',
              'urinary_symptoms'
            ],
            'reviewOfSystems': [
              'gastrointestinal',
              'genitourinary',
              'constitutional_symptoms'
            ],
            'PMH': ['previous_surgery', 'medical_conditions', 'medications'],
            'FSH': ['family_history', 'social_history'],
          },
          followUpQuestions: [
            FollowUpQuestion(
              type: 'short_answer',
              question: 'What is your most likely diagnosis?',
            ),
            FollowUpQuestion(
              type: 'list',
              question: 'What clinical signs would you look for on examination?',
            ),
            FollowUpQuestion(
              type: 'short_answer',
              question: 'What investigation would confirm your diagnosis?',
            ),
          ],
          answers: {
            'diagnosis': 'Acute appendicitis',
            'signs': ['McBurney\'s point tenderness', 'Rovsing\'s sign', 'Guarding', 'Rebound tenderness'],
            'investigation': 'CT scan abdomen/pelvis'
          },
          maxScore: 18,
        ),
      ];

      // Sample Obstetrics & Gynecology Cases
      List<CaseModel> obgynCases = [
        CaseModel(
          id: 'obgyn_case_01',
          departmentId: 'obstetrics_gynecology',
          title: 'Missed Period in Young Woman',
          scenario: '''
Miss Sarah Thompson, a 24-year-old marketing executive, presents with a 6-week history of missed periods. She is sexually active with her long-term partner and they use condoms inconsistently. She reports feeling nauseous in the mornings and has noticed breast tenderness. She appears anxious about the consultation.

She mentions that her periods are usually regular with a 28-day cycle.
          ''',
          clerkingChecklist: {
            'biodata': ['age', 'occupation', 'relationship_status'],
            'presentingComplaint': ['missed_periods', 'duration', 'last_menstrual_period'],
            'HPC': [
              'menstrual_history',
              'contraception_use',
              'sexual_history',
              'pregnancy_symptoms',
              'bleeding',
              'pain'
            ],
            'reviewOfSystems': [
              'gynecological',
              'gastrointestinal',
              'breast_changes',
              'urinary_symptoms'
            ],
            'PMH': ['previous_pregnancies', 'gynecological_history', 'medications'],
            'FSH': ['family_planning', 'support_system', 'smoking', 'alcohol'],
          },
          followUpQuestions: [
            FollowUpQuestion(
              type: 'short_answer',
              question: 'What is the most likely diagnosis?',
            ),
            FollowUpQuestion(
              type: 'short_answer',
              question: 'What initial test would you perform?',
            ),
            FollowUpQuestion(
              type: 'list',
              question: 'What counseling points would you discuss?',
            ),
          ],
          answers: {
            'diagnosis': 'Pregnancy',
            'test': 'Urine pregnancy test (beta-hCG)',
            'counseling': ['Prenatal care', 'Folic acid', 'Lifestyle advice', 'Options counseling']
          },
          maxScore: 20,
        ),
      ];

      // Add all cases to batch
      List<CaseModel> allCases = [...medicineCases, ...surgeryCases, ...obgynCases];
      
      for (CaseModel caseModel in allCases) {
        DocumentReference ref = _firestore
            .collection(AppConstants.casesCollection)
            .doc(caseModel.id);
        batch.set(ref, caseModel.toMap());
      }

      await batch.commit();
      print('Sample cases seeded successfully');

    } catch (e) {
      print('Error seeding sample cases: ${e.toString()}');
      throw Exception('Failed to seed sample cases: ${e.toString()}');
    }
  }

  Future<void> seedAllSampleData() async {
    try {
      // First seed departments if they don't exist
      QuerySnapshot deptSnapshot = await _firestore
          .collection(AppConstants.departmentsCollection)
          .limit(1)
          .get();

      if (deptSnapshot.docs.isEmpty) {
        await _seedDepartments();
      }

      // Then seed cases
      await seedSampleCases();

    } catch (e) {
      print('Error seeding all sample data: ${e.toString()}');
      throw Exception('Failed to seed sample data: ${e.toString()}');
    }
  }

  Future<void> _seedDepartments() async {
    try {
      WriteBatch batch = _firestore.batch();

      List<Department> departments = [
        Department(id: 'medicine', name: 'Medicine', icon: '🩺'),
        Department(id: 'surgery', name: 'Surgery', icon: '🔪'),
        Department(id: 'obstetrics_gynecology', name: 'Obstetrics & Gynecology', icon: '👶'),
        Department(id: 'pediatrics', name: 'Pediatrics', icon: '🧸'),
        Department(id: 'psychiatry', name: 'Psychiatry', icon: '🧠'),
        Department(id: 'emergency', name: 'Emergency Medicine', icon: '🚨'),
      ];

      for (Department dept in departments) {
        DocumentReference ref = _firestore
            .collection(AppConstants.departmentsCollection)
            .doc(dept.id);
        batch.set(ref, dept.toMap());
      }

      await batch.commit();
      print('Departments seeded successfully');

    } catch (e) {
      print('Error seeding departments: ${e.toString()}');
      throw Exception('Failed to seed departments: ${e.toString()}');
    }
  }
}