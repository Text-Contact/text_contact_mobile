import "package:flutter_contacts/flutter_contacts.dart";

initializeContacts() async {
  // Request Contacts Permission
  return await FlutterContacts.requestPermission(readonly: true);
}

Future<List<Contact>> getAllContacts() async {
  await initializeContacts();
  return await FlutterContacts.getContacts(
      withProperties: true, withPhoto: true);
}
