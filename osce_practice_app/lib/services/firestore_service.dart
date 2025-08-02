import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/case_model.dart';
import '../models/answer_model.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Departments
  Future<List<Department>> getDepartments() async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.departmentsCollection)
          .orderBy('name')
          .get();

      return snapshot.docs
          .map((doc) => Department.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch departments: ${e.toString()}');
    }
  }

  // Cases
  Future<List<CaseModel>> getCasesByDepartment(String departmentId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.casesCollection)
          .where('departmentId', isEqualTo: departmentId)
          .orderBy('title')
          .get();

      return snapshot.docs
          .map((doc) => CaseModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch cases: ${e.toString()}');
    }
  }

  Future<CaseModel?> getCaseById(String caseId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.casesCollection)
          .doc(caseId)
          .get();

      if (doc.exists) {
        return CaseModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch case: ${e.toString()}');
    }
  }

  // User Management
  Future<void> createUserDocument(UserModel user) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.id)
          .set(user.toMap());
    } catch (e) {
      throw Exception('Failed to create user document: ${e.toString()}');
    }
  }

  Future<UserModel?> getUserById(String userId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (doc.exists) {
        return UserModel.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch user: ${e.toString()}');
    }
  }

  Future<void> updateUserProgress(String userId, Map<String, dynamic> progress) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .update({'progress': progress});
    } catch (e) {
      throw Exception('Failed to update user progress: ${e.toString()}');
    }
  }

  // Attempts
  Future<String> saveAttempt(AttemptModel attempt) async {
    try {
      DocumentReference doc = await _firestore
          .collection(AppConstants.attemptsCollection)
          .add(attempt.toMap());
      return doc.id;
    } catch (e) {
      throw Exception('Failed to save attempt: ${e.toString()}');
    }
  }

  Future<void> updateAttempt(String attemptId, AttemptModel attempt) async {
    try {
      await _firestore
          .collection(AppConstants.attemptsCollection)
          .doc(attemptId)
          .update(attempt.toMap());
    } catch (e) {
      throw Exception('Failed to update attempt: ${e.toString()}');
    }
  }

  Future<List<AttemptModel>> getUserAttempts(String userId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.attemptsCollection)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AttemptModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch user attempts: ${e.toString()}');
    }
  }

  Future<List<AttemptModel>> getCaseAttempts(String userId, String caseId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(AppConstants.attemptsCollection)
          .where('userId', isEqualTo: userId)
          .where('caseId', isEqualTo: caseId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => AttemptModel.fromMap(
              doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch case attempts: ${e.toString()}');
    }
  }

  // Statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      List<AttemptModel> attempts = await getUserAttempts(userId);
      
      if (attempts.isEmpty) {
        return {
          'totalAttempts': 0,
          'averageScore': 0.0,
          'bestScore': 0.0,
          'completedCases': 0,
          'totalTimeSpent': Duration.zero,
        };
      }

      int totalAttempts = attempts.length;
      int completedAttempts = attempts.where((a) => a.completed).length;
      double averageScore = attempts
          .where((a) => a.completed)
          .map((a) => a.getPercentageScore())
          .fold(0.0, (sum, score) => sum + score) / 
          (completedAttempts > 0 ? completedAttempts : 1);
      
      double bestScore = attempts
          .where((a) => a.completed)
          .map((a) => a.getPercentageScore())
          .fold(0.0, (max, score) => score > max ? score : max);

      Set<String> uniqueCases = attempts
          .where((a) => a.completed)
          .map((a) => a.caseId)
          .toSet();

      Duration totalTime = attempts.fold(
        Duration.zero,
        (total, attempt) => total + attempt.timeSpent,
      );

      return {
        'totalAttempts': totalAttempts,
        'averageScore': averageScore,
        'bestScore': bestScore,
        'completedCases': uniqueCases.length,
        'totalTimeSpent': totalTime,
      };
    } catch (e) {
      throw Exception('Failed to fetch user stats: ${e.toString()}');
    }
  }

  // Batch operations for seeding data
  Future<void> seedDepartments() async {
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
    } catch (e) {
      throw Exception('Failed to seed departments: ${e.toString()}');
    }
  }
}