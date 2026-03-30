import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../models/event_feed_item.dart';

class EventCalendarLinkBuilder {
  const EventCalendarLinkBuilder._();

  static Uri build(EventFeedItem item) {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS)) {
      return _buildAppleCalendarDataUri(item);
    }

    return _buildGoogleCalendarUri(item);
  }

  static Uri _buildGoogleCalendarUri(EventFeedItem item) {
    final startUtc = item.startDate.toUtc();
    final endUtc = startUtc.add(const Duration(hours: 2));
    final formatter = DateFormat("yyyyMMdd'T'HHmmss'Z'");
    return Uri.https('www.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': item.title,
      'details': item.description,
      'location': item.address,
      'dates': '${formatter.format(startUtc)}/${formatter.format(endUtc)}',
    });
  }

  static Uri _buildAppleCalendarDataUri(EventFeedItem item) {
    final startUtc = item.startDate.toUtc();
    final endUtc = startUtc.add(const Duration(hours: 2));
    final formatter = DateFormat("yyyyMMdd'T'HHmmss'Z'");

    final ics = [
      'BEGIN:VCALENDAR',
      'VERSION:2.0',
      'PRODID:-//MeetApp//Event//EN',
      'BEGIN:VEVENT',
      'UID:${item.id}@meet_app',
      'DTSTAMP:${formatter.format(DateTime.now().toUtc())}',
      'DTSTART:${formatter.format(startUtc)}',
      'DTEND:${formatter.format(endUtc)}',
      'SUMMARY:${_escapeIcs(item.title)}',
      'DESCRIPTION:${_escapeIcs(item.description)}',
      'LOCATION:${_escapeIcs(item.address)}',
      'END:VEVENT',
      'END:VCALENDAR',
    ].join('\r\n');

    return Uri.dataFromString(
      ics,
      mimeType: 'text/calendar',
      encoding: utf8,
    );
  }

  static String _escapeIcs(String value) {
    return value
        .replaceAll('\\', '\\\\')
        .replaceAll(';', '\\;')
        .replaceAll(',', '\\,')
        .replaceAll('\n', '\\n');
  }
}
