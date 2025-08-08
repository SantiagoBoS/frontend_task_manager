import 'dart:developer' as console;

import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskListScreen extends StatefulWidget{
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen>{
  final TaskService taskService = TaskService(); //Servicio para conectarse al backend
  late Future<List<Task>> futureTasks; //Para poder guardar las tareas

  @override
  void initState(){
    super.initState();
    //Ejecucion del API para traer las tareas
    loadTask();
  }

  //Para recargar las tareas
  void loadTask(){
    setState((){
      futureTasks = taskService.getTasks();
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestor de Tareas'),
        backgroundColor: Colors.blue,
      ),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot){
          try{
            if(snapshot.connectionState == ConnectionState.waiting){
              //Cargando las tareas
              return const Center(child: CircularProgressIndicator());
            }else if(!snapshot.hasData || snapshot.data!.isEmpty){
              //Si no encuentra tareas
              return const Center(child: Text('No hay tareas disponibles'));
            }else if (snapshot.hasError){
              //Si ocurre algun error
              return Center(child: Text('Error: ${snapshot.error}'));
            }
          }catch (e) {
            throw Exception('Error al mostrar las tareas. Código: ${e.hashCode}');
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index){
              Task task = snapshot.data![index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text('Estado: ${task.status}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Boton Editar
                    IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: (){

                        },
                    ),
                    //Boton Eliminar
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        bool confirmar = await showDialogDeleteTask(context);
                        if (confirmar) {
                          await taskService.deleteTask(task.id);
                          //Para mostar un toltip MELO
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Tarea eliminada con éxito")),
                          );
                          loadTask();
                        }
                      },
                    )
                  ],
                ),
              );
            }
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTask,
        backgroundColor: Colors.white30,
        label: const Text('Crear nueva tarea'),
      ),
    );
  }

  void _createTask(){
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Crear una nueva tarea'),
        content: const Text('FORMULARIO DE CREACION'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar')
          ),
          ElevatedButton(
            onPressed: () {
              //LOGICA PARA EL FORMULARIO
              Navigator.pop(context);
              loadTask();
            },
            child: const Text('Guardar')
          )
        ],
      )
    );
  }

  Future<bool> showDialogDeleteTask(BuildContext context) async{
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Está seguro que desea eliminar esta tarea?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar')
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar')
          )
        ],
      )
    ) ?? false;
  }
}

