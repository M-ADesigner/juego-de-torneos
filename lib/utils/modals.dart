import 'package:flutter/material.dart';

void mostrarModal(BuildContext context, text, title) {
  showModalBottomSheet(
    context: context,
    builder: (BuildContext context) {
      return Container(
        // Contenido del modal
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            Text(
              '$text',
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop(); // Cerrar el modal
              },
              child: const Text('Cerrar'),
            ),
          ],
        ),
      );
    },
  );
}
