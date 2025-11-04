
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  //get collection
  final CollectionReference complaints = FirebaseFirestore.instance.collection('complaints');
  final CollectionReference pensioners = FirebaseFirestore.instance.collection('pensioners');
  final CollectionReference payouthistory = FirebaseFirestore.instance.collection('payouthistory');
  final DocumentReference systemBalanceRef = FirebaseFirestore.instance.collection('payouthistory').doc('systemBalance');

  //CREATE
  Future<void> addComplaint(String pensionerNames, String complaintBody) {
    final docRef = complaints.doc();
    return docRef.set({
      'id': docRef.id,
      'complaintNumber': docRef.id,
      'pensionerNames': pensionerNames,
      'complaintBody': complaintBody,
      'datePublished': FieldValue.serverTimestamp(),
      'complaintResponse': 'Pending | Tsoa u ntso lebelletse karabo',
      'dateResponded': null,
    });
  }

  Future<void> addComplaintMessage(String complaintId, String message, {String sender = 'admin'}) async {
    final messagesRef = complaints.doc(complaintId).collection('messages');
    await messagesRef.add({
      'message': message,
      'sender': sender,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await complaints.doc(complaintId).set({
      'complaintResponse': message,
      'dateResponded': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

Future<void> addPensioner(String pensionerNames, String pin, String title, String gender, String idNumber, dateOfBirth, phoneNumber, String location, String guardianNames, String guardianRelationship, String guardianNumber, {String status = 'Active', double balance = 0.00, int }) {
    return pensioners.add ({
      'pensionerNames': pensionerNames,
      'pin' : pin,
      'title': title,
      'gender': gender,
      'idNumber': idNumber,
      'dateOfBirth' : dateOfBirth,
      'phoneNumber' : phoneNumber,
      'location' : location,
      'guardianNames' : guardianNames,
      'guardianRelationship': guardianRelationship,
      'guardianNumber' : guardianNumber,
      'dateJoined': FieldValue.serverTimestamp(),
      'status': status,
      'balance': balance
  });
}

Future<void> addPayout(String pensionerNames, double payoutAmount, {String sender = 'admin'}) {
  final docRef = payouthistory.doc();      
      return docRef.set({
      'id': docRef.id,
      'payoutNumber': docRef.id,
      'pensionerNames': pensionerNames,
      'payoutAmount': payoutAmount,
      'datePublished': FieldValue.serverTimestamp()
      });
}

Future<void> addSchedule(String pensionMessage, pensionDate) {
    return payouthistory.add ({
      'pensionMessage': pensionMessage,
      'pensionDate': pensionDate,
      'datePosted': FieldValue.serverTimestamp()
  });
}

  //RETRIEVE

Future<Map<String, dynamic>?> getPensionerById(String id) async {
    final doc = await pensioners.doc(id).get();
    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>? ?? {};

    final rawDate = data['dateOfBirth'];
    DateTime dateOfBirth;
    if (rawDate is Timestamp) {
      dateOfBirth = rawDate.toDate();
    } else if (rawDate is String) {
      dateOfBirth = DateTime.tryParse(rawDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
    } else if (rawDate is DateTime) {
      dateOfBirth = rawDate;
    } else {
      dateOfBirth = DateTime.fromMillisecondsSinceEpoch(0);
    }

    final rawDateJoined = data['dateJoined'];
    DateTime? dateJoined;
    if (rawDateJoined is Timestamp) {
      dateJoined = rawDateJoined.toDate();
    } else if (rawDateJoined is String) {
      dateJoined = DateTime.tryParse(rawDateJoined);
    } else if (rawDateJoined is DateTime) {
      dateJoined = rawDateJoined;
    } else {
      dateJoined = null;
    }
return {
      'title': data['title']?.toString() ?? '',
      'pensionerNames': data['pensionerNames']?.toString() ?? '',
      'gender': data['gender']?.toString() ?? '',
      'idNumber': data['idNumber']?.toString() ?? '',
      'dateOfBirth': dateOfBirth,
      'phoneNumber': data['phoneNumber']?.toString() ?? '',
      'location': data['location']?.toString() ?? '',
      'guardianNames': data['guardianNames']?.toString() ?? '',
      'guardianRelationship': data['guardianRelationship']?.toString() ?? '',
      'guardianNumber': data['guardianNumber']?.toString() ?? '',
      'dateJoined': dateJoined,
      'status': data['status']?.toString() ?? '',
      'balance': (data['balance'] as num?)?.toDouble() ?? 0.0,
    };
  }

Stream<List<Map<String, dynamic>>> allPensioners() {
    return pensioners.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final rawDate = data['dateOfBirth'];
        DateTime dateOfBirth;
        if (rawDate is Timestamp) {
          dateOfBirth = rawDate.toDate();
        } else if (rawDate is String) {
          dateOfBirth = DateTime.tryParse(rawDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
        } else if (rawDate is DateTime) {
          dateOfBirth = rawDate;
        } else {
          dateOfBirth = DateTime.fromMillisecondsSinceEpoch(0);
        }
final rawDateJoined = data['dateJoined'];
        DateTime? dateJoined;
        if (rawDateJoined is Timestamp) {
          dateJoined = rawDateJoined.toDate();
        } else if (rawDateJoined is String) {
          dateJoined = DateTime.tryParse(rawDateJoined);
        } else if (rawDateJoined is DateTime) {
          dateJoined = rawDateJoined;
        } else {
          dateJoined = null;
        }

        return {
          'title': data['title']?.toString() ?? '',
          'pensionerNames': data['pensionerNames']?.toString() ?? '',
          'gender': data['gender']?.toString() ?? '',
          'idNumber': data['idNumber']?.toString() ?? '',
          'dateOfBirth': dateOfBirth,
          'phoneNumber': data['phoneNumber']?.toString() ?? '',
          'location': data['location']?.toString() ?? '',
          'guardianNames':data['guardianNames']?.toString() ?? '',
          'guardianRelationship':data['guardianRelationship']?.toString() ?? '',
          'guardianNumber':data['guardianNumber']?.toString() ?? '',
          'dateJoined': dateJoined,
          'status':data['status']?.toString() ?? '',
        };
      }).toList();
    });
  }

Stream<List<Map<String, dynamic>>> approvedPensioners() {
    return pensioners.where('status', isEqualTo: 'Active').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final docId = doc.id;
        final rawDate = data['dateOfBirth'];
        DateTime dateOfBirth;
        if (rawDate is Timestamp) {
          dateOfBirth = rawDate.toDate();
        } else if (rawDate is String) {
          dateOfBirth = DateTime.tryParse(rawDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
        } else if (rawDate is DateTime) {
          dateOfBirth = rawDate;
        } else {
          dateOfBirth = DateTime.fromMillisecondsSinceEpoch(0);
        }
final rawDateJoined = data['dateJoined'];
        DateTime? dateJoined;
        if (rawDateJoined is Timestamp) {
          dateJoined = rawDateJoined.toDate();
        } else if (rawDateJoined is String) {
          dateJoined = DateTime.tryParse(rawDateJoined);
        } else if (rawDateJoined is DateTime) {
          dateJoined = rawDateJoined;
        } else {
          dateJoined = null;
        }

        return {
          'docId': docId,
          'title': data['title']?.toString() ?? '',
          'pensionerNames': data['pensionerNames']?.toString() ?? '',
          'gender': data['gender']?.toString() ?? '',
          'idNumber': data['idNumber']?.toString() ?? '',
          'dateOfBirth': dateOfBirth,
          'phoneNumber': data['phoneNumber']?.toString() ?? '',
          'location': data['location']?.toString() ?? '',
          'guardianNames':data['guardianNames']?.toString() ?? '',
          'guardianRelationship':data['guardianRelationship']?.toString() ?? '',
          'guardianNumber':data['guardianNumber']?.toString() ?? '',
          'dateJoined': dateJoined,
          'status':data['status']?.toString() ?? '',
        };
      }).toList();
    });
  }


  Stream<List<Map<String, dynamic>>> viewBlance() {
    return payouthistory.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        
        return {
          'currentbalance': data['currentbalance'] ?? 0,
        };
      }).toList();
    });
  }

  Stream<List<Map<String, dynamic>>> allComplaints() {
    return complaints.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>? ?? {};
        final rawDate = data['datePublished'];
        DateTime datePublished;
        if (rawDate is Timestamp) {
          datePublished = rawDate.toDate();
        } else if (rawDate is String) {
          datePublished = DateTime.tryParse(rawDate) ?? DateTime.fromMillisecondsSinceEpoch(0);
        } else if (rawDate is DateTime) {
          datePublished = rawDate;
        } else {
          datePublished = DateTime.fromMillisecondsSinceEpoch(0);
        }
final rawDateResponded = data['dateResponded'];
        DateTime? dateResponded;
        if (rawDateResponded is Timestamp) {
          dateResponded = rawDateResponded.toDate();
        } else if (rawDateResponded is String) {
          dateResponded = DateTime.tryParse(rawDateResponded);
        } else if (rawDateResponded is DateTime) {
          dateResponded = rawDateResponded;
        } else {
          dateResponded = null;
        }

        return {
          'id': doc.id,
          'complaintNumber': doc.id,
          'pensionerNames': data['pensionerNames']?.toString() ?? '',
          'complaintBody': data['complaintBody']?.toString() ?? '',
          'complaintResponse': data['complaintResponse']?.toString() ?? '',
          'datePublished': datePublished,
          'dateResponded': dateResponded,
        };
      }).toList();
    });
  }

 Stream<List<Map<String, dynamic>>> complaintMessages(String complaintId) {
    final ref = complaints.doc(complaintId).collection('messages').orderBy('createdAt', descending: false);
    return ref.snapshots().map((snap) {
      return snap.docs.map((d) {
        final data = d.data() as Map<String, dynamic>? ?? {};
        final raw = data['createdAt'];
        DateTime? createdAt;
        if (raw is Timestamp) createdAt = raw.toDate();
        return {
          'id': d.id,
          'message': data['message']?.toString() ?? '',
          'sender': data['sender']?.toString() ?? '',
          'createdAt': createdAt,
        };
      }).toList();
    });
  }

  Stream<List<DocumentSnapshot>> approvedPensionerDocs() {
  return FirebaseFirestore.instance
    .collection('pensioners')
    .where('status', isEqualTo: 'Active')
    .snapshots()
    .map((snapshot) => snapshot.docs);
}

  //UPDATE

  Future<void> respondToComplaint(String complaintNumber, String complaintResponse) {
    return complaints.doc(complaintNumber).set({
      'complaintResponse': complaintResponse, 
      'dateResponded': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateStatus(String idNumber, String status) async {
    final querySnapshot = await pensioners.where('idNumber', isEqualTo: idNumber).get();
    if (querySnapshot.docs.isEmpty) {
      throw Exception('No pensioner found with this identification number');
    }

    final batch = FirebaseFirestore.instance.batch();
    for (final doc in querySnapshot.docs) {
      batch.set(doc.reference, {
        'status': status
      }, SetOptions(merge: true));
    }
    await batch.commit();
  }



Future<String> processPayments(List<DocumentSnapshot> pensioners) async {
  const double paymentAmount = 500.0;

  if (pensioners.isEmpty) {
    throw Exception('No pensioners were provided to process.');
  }

  try {
    final systemBalanceDoc = await systemBalanceRef.get();

    if (!systemBalanceDoc.exists || systemBalanceDoc.data() == null) {
      throw Exception('System funds document not found. Please initialize the system balance.');
    }

    final systemBalanceData = systemBalanceDoc.data() as Map<String, dynamic>;
    final currentSystemBalance =
        (systemBalanceData['currentbalance'] as num?)?.toDouble() ?? 0.0;

    final totalRequired = pensioners.length * paymentAmount;

    if (currentSystemBalance < totalRequired) {
      throw Exception(
        'Insufficient funds: Available M\$${currentSystemBalance.toStringAsFixed(2)}, Required M\$${totalRequired.toStringAsFixed(2)}',
      );
    }

    for (final pensioner in pensioners) {
      final pensionerData = pensioner.data() as Map<String, dynamic>;
      final pensionerCurrentBalance =
          (pensionerData['balance'] as num?)?.toDouble() ?? 0.0;
      final pensionerNames = pensionerData['pensionerNames'] as String? ?? 'N/A';

      await pensioner.reference.update({
        'balance': pensionerCurrentBalance + paymentAmount,
      });

      await systemBalanceRef.collection('balance').add({
        'pensionerNames': pensionerNames,
        'payoutAmount': paymentAmount,
        'datePaid': FieldValue.serverTimestamp(),
      });
    }

    await systemBalanceRef.update({
      'currentbalance': currentSystemBalance - totalRequired,
    });

    return 'Success! Paid M${paymentAmount.toStringAsFixed(2)} to ${pensioners.length} pensioners. Remaining: M${(currentSystemBalance - totalRequired).toStringAsFixed(2)}';
  } catch (e, stack) {
    debugPrint('Non-transactional Payment Error: $e');
    debugPrint('Stack trace: $stack');
    throw Exception('Payment failed: ${e.toString()}');
  }
}


  //DELETE

  /*Future<void> delete(String pensionerNames) async {
    await pensioners.doc(pensionerNames).delete();
    }
    }*/
}