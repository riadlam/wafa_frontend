import 'package:flutter/material.dart';

class LoyaltyCardModel {
  final String id;
  final String name;
  final String description;
  final int totalStamps;
  final int earnedStamps;
  final bool isSubscribed;
  
  // Support for both icon and image
  final IconData? icon;
  final String? imageUrl;
  
  // Visual customization
  final Color backgroundColor;
  final Color? secondaryColor;
  final Color textColor;
  final Color stampColor;
  final Color stampFillColor;

  LoyaltyCardModel({
    required this.id,
    required this.name,
    this.description = '',
    required this.totalStamps,
    required this.earnedStamps,
    this.isSubscribed = false,
    this.icon,
    this.imageUrl,
    Color? backgroundColor,
    this.secondaryColor,
    Color? textColor,
    Color? stampColor,
    Color? stampFillColor,
  }) : 
    assert(icon != null || imageUrl != null, 'Either icon or imageUrl must be provided'),
    assert(earnedStamps <= totalStamps, 'Earned stamps cannot exceed total stamps'),
    backgroundColor = backgroundColor ?? const Color(0xFFFF8C42),
    textColor = textColor ?? Colors.white,
    stampColor = stampColor ?? Colors.white.withOpacity(0.6),
    stampFillColor = stampFillColor ?? Colors.white;

  // Helper method to create a copy with some updated fields
  LoyaltyCardModel copyWith({
    String? id,
    String? name,
    String? description,
    int? totalStamps,
    int? earnedStamps,
    bool? isSubscribed,
    IconData? icon,
    String? imageUrl,
    Color? backgroundColor,
    Color? secondaryColor,
    Color? textColor,
    Color? stampColor,
    Color? stampFillColor,
  }) {
    return LoyaltyCardModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      totalStamps: totalStamps ?? this.totalStamps,
      earnedStamps: earnedStamps ?? this.earnedStamps,
      isSubscribed: isSubscribed ?? this.isSubscribed,
      icon: icon ?? this.icon,
      imageUrl: imageUrl ?? this.imageUrl,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      textColor: textColor ?? this.textColor,
      stampColor: stampColor ?? this.stampColor,
      stampFillColor: stampFillColor ?? this.stampFillColor,
    );
  }
}
