import 'dart:convert'; //JSON en objetos dart
import 'package:http/http.dart' as http;
import '../models/task.dart';

//Conexion con el backend
class TaskService{
  //Warning: Cambiar la URL si se tiene otro puerto
  //Para ejecutarlo en web
  //static const String baseUrl = 'http://localhost:3000';
  //IP para emulador
  static const String baseUrl = 'http://10.0.2.2:3000';

  //Obtener las tareas
  Future<List<Task>> getTasks() async{
    final response = await http.get(Uri.parse('$baseUrl/tasks'));
    if(response.statusCode == 200){
      List<dynamic> bodyResponse = jsonDecode(response.body);
      return bodyResponse.map((jsonResponse) => Task.fromJson(jsonResponse)).toList();
    }else{
      throw Exception('Respuesta no satisfactoria al momento de obtener las tareas. Código: ${response.statusCode}');
    }
  }

  //Crear una nueva tarea
  Future<Task> createTask( Task task ) async{
    var createTask = {
      'title': task.title,
      'description': task.description,
      'status': task.status
    };
    var response = await http.post(
      Uri.parse('$baseUrl/tasks'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(createTask)
    );
    if(response.statusCode == 201){
      return Task.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Respuesta no satisfactoria al momento de crear una tarea. Código: ${response.statusCode}');
    }
  }

  //Actualizar una tarea
  Future<Task> updateTask(int id, Task task ) async{
    var editTask = {
      'title': task.title,
      'description': task.description,
      'status': task.status
    };
    var response = await http.put(
        Uri.parse('$baseUrl/tasks/$id'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(editTask)
    );
    if(response.statusCode == 200){
      return Task.fromJson(jsonDecode(response.body));
    }else{
      throw Exception('Respuesta no satisfactoria al momento de actualizar una tarea. Código: ${response.statusCode}');
    }
  }

  //Eliminar una tarea
  Future<String> deleteTask(int id) async{
    var response = await http.delete(Uri.parse('$baseUrl/tasks/$id'));
    if(response.statusCode != 200 && response.statusCode != 204){
      throw Exception('Respuesta no satisfactoria al momento de eliminar una tarea. Código: ${response.statusCode}');
    }else{
      return 'Tarea eliminada con éxito';
    }
  }
}