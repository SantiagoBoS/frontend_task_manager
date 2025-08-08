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
    futureTasks = taskService.getTasks();
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
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
      ),
      body: FutureBuilder<List<Task>>(
        future: futureTasks,
        builder: (context, snapshot){
          try{
            //Manejo de error y conexion con el back
            if(snapshot.connectionState == ConnectionState.waiting){
              //Cargando las tareas
              return const Center(child: CircularProgressIndicator());
            }else if (snapshot.hasError){
              //Si ocurre algun error
              return Center(child: Text('Error: ${snapshot.error}'));
            }else if(!snapshot.hasData || snapshot.data!.isEmpty){
              //Si no encuentra tareas
              return const Center(child: Text('No hay tareas disponibles'));
            }
          }catch (e) {
            throw Exception('Error al mostrar las tareas. Código: ${e.hashCode}');
          }

          //Logica para los botones en cada tarea
          return ListView.separated(
            itemCount: snapshot.data!.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index){
              Task task = snapshot.data![index];
              return ListTile(
                tileColor: getStatusColor(task.status),
                title: Text(task.title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
                subtitle: Text('Estado: ${getStatusLabel(task.status)}',
                  style: const TextStyle(fontSize: 14)
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Boton Editar
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.black),
                      onPressed: (){
                        _editTask(task);
                      },
                    ),
                    //Boton Eliminar
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.black),
                      onPressed: () async {
                        bool confirm = await showDialogDeleteTask(context);
                        if (confirm) {
                          await taskService.deleteTask(task.id);
                          //Si se completa, mostrar un mensaje en la parte inferior de la pantalla
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
      //Boton flotante para crear una tarea
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createTask,
        backgroundColor: Colors.white54,
        label: const Text('Crear una nueva tarea',
          style: TextStyle(fontSize: 15),
        ),
      ),
    );
  }

  //Crear una nueva tarea
  Future<void> _createTask() async {
    var createTask = await showTaskFormDialog(context, taskService: taskService);
    if (createTask){
      //Si se completa, mostrar un mensaje en la parte inferior de la pantalla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tarea creada con éxito")),
      );
      loadTask();
    }
  }

  //Editar una tarea
  Future<void> _editTask(Task task) async {
    var editTask = await showTaskFormDialog(
      context,
      existing: task,
      taskService: taskService
    );
    if (editTask){
      //Si se completa, mostrar un mensaje en la parte inferior de la pantalla
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tarea editada con éxito")),
      );
      loadTask();
    }
  }

  //Modal para la creacion y actualizacion de una tarea
  Future<bool> showTaskFormDialog(BuildContext context, {
    Task? existing,
    required TaskService taskService,
  }) async {
    var formKey = GlobalKey<FormState>();
    var titleController = TextEditingController(text: existing?.title ?? '');
    var descriptionController = TextEditingController(text: existing?.description ?? '');
    var status = existing?.status ?? 'pending';

    bool isSaving = false;

    var result = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context){
        return StatefulBuilder(
          builder: (context, setStateDialog){
            return AlertDialog(
              title: Text(existing == null ? 'Crear tarea' : 'Editar tarea'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Titulo'),
                        validator: (value){
                          if(value == null || value.trim().isEmpty){
                            return 'El titulo es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(labelText: 'Descripcion'),
                        maxLines: 2,
                        validator: (value){
                          if(value == null || value.trim().isEmpty){
                            return 'La descripcion es obligatorio';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: status,
                        decoration: const InputDecoration(labelText: 'Estado'),
                        items: const[
                          DropdownMenuItem(value: 'pending', child: Text('Pendiente')),
                          DropdownMenuItem(value: 'in_progress', child: Text('En progreso')),
                          DropdownMenuItem(value: 'completed', child: Text('Completada')),
                        ],
                        onChanged: (value){
                          if(value != null) setStateDialog(() => status = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      if(isSaving) const LinearProgressIndicator(),
                    ],
                  )
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSaving ? null : () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar')
                ),
                ElevatedButton(
                  onPressed: isSaving ? null : () async{
                    if(!formKey.currentState!.validate()) return;

                    setStateDialog(() => isSaving = true);

                    try{
                      if(existing == null){
                        await taskService.createTask(Task(
                          id: 0,
                          title: titleController.text.trim(),
                          description: descriptionController.text.trim(),
                          status: status
                        ));
                      }else{
                        await taskService.updateTask(
                          existing.id,
                          Task(
                            id: existing.id,
                            title: titleController.text.trim(),
                            description: descriptionController.text.trim(),
                            status: status
                          )
                        );
                      }
                      Navigator.of(context).pop(true);
                    }catch(e){
                      setStateDialog(() => isSaving = false);
                      //Si se completa, mostrar un mensaje en la parte inferior de la pantalla
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error al guardar: $e'))
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  child: Text(existing == null ? 'Crear' : 'Guardar')
                )
              ],
            );
          }
        );
      }
    );
    return result == true;
  }

  //Eliminar una tarea modal
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
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white
            ),
            child: const Text('Eliminar')
          )
        ],
      )
    ) ?? false;
  }

  //Para mostrar el tipo de estado de la tarea
  String getStatusLabel(String status){
    switch (status) {
      case 'pending':
        return 'Pendiente';
      case 'in_progress':
        return 'En progreso';
      case 'completed':
        return 'Completada';
      default:
        return status;
    }
  }

  //Para cambiar el color de fondo segun el estado de la tarea
  Color getStatusColor(String status){
    switch (status) {
      case 'pending':
        return Colors.grey.shade200;
      case 'in_progress':
        return Colors.orange.shade200;
      case 'completed':
        return Colors.yellow.shade100;
      default:
        return Colors.white;
    }
  }
}

