import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/pages/screens/expenses/expenses.dart';

class Category {
  final String id;
  final String name;
  final String description;
  final int iconCodePoint; // Change to int to store icon code point
  final String color;
  final List<Expense> expenses; // Add expenses parameter
  double totalAmount; // Add totalAmount parameter

  Category({
    required this.id,
    required this.name,
    required this.description,
    required this.iconCodePoint,
    required this.color,
    this.expenses = const [], // Provide a default value for expenses
    this.totalAmount = 0.0, // Set initial value for totalAmount
  });

  IconData get icon => IconData(
        iconCodePoint,
        fontFamily: 'MaterialIcons',
      );

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'iconCodePoint': iconCodePoint, // Store icon code point as int
      'color': color,
      'totalAmount': totalAmount.toDouble(),
      'timestamp': Timestamp.now(), // Add timestamp field
    };
  }

  factory Category.fromMap(String id, Map<String, dynamic> map,
      [List<Expense>? expenses]) {
    return Category(
      id: id,
      name: map['name'],
      description: map['description'],
      iconCodePoint: map['iconCodePoint'],
      //  ?? Icons.error.codePoint,
      color: map['color'],
      totalAmount: map['totalAmount'] ?? 0.0,
      expenses: expenses ?? [],
    );
  }
}
