import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/incident_model.dart';

class IncidentProvider extends ChangeNotifier {
  List<Incident> incidents = [];
  final _db = FirebaseFirestore.instance;

  void fetchRealtime() {
    _db.collection('incidents').orderBy('createdAt', descending: true).snapshots().listen((snap) {
      incidents = snap.docs.map((doc) => Incident.fromMap(doc.data(), doc.id)).toList();
      notifyListeners();
    });
  }

  Future<void> addIncident(Incident item) async => await _db.collection('incidents').add(item.toMap());
  Future<void> deleteIncident(String id) async => await _db.collection('incidents').doc(id).delete();
  Future<void> updateIncident(String id, Map<String, dynamic> updates) async => await _db.collection('incidents').doc(id).update(updates);

  Incident? getIncidentById(String id) {
    for (final incident in incidents) {
      if (incident.id == id) {
        return incident;
      }
    }
    return null;
  }
}