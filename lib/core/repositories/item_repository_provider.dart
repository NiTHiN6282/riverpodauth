import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';


final itemRepositoryProvider = Provider((ref)=> ItemRepository());

class ItemRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> writeItem(Item item, {File? file}) async {
    final ref =
        _firestore.collection("items").doc(item.id.isEmpty ? null : item.id);
    final String? imageUrl = file != null
        ? await (await _storage.ref("images").child(ref.id).putFile(file))
            .ref
            .getDownloadURL()
        : null;

    await ref.set(
      item.copyWith(image: imageUrl).toMap(),
      SetOptions(merge: true),
    );
  }

  Stream<List<Item>> get itemsStream => _firestore
      .collection('items')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (event) => event.docs
            .map(
              (e) => Item.fromFirestore(e),
            )
            .toList(),
      );
}
