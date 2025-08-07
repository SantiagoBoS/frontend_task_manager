

class Task{
  //Variables segun lo que se crea desde el backend
  final int id;
  final String title;
  final String description;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
  });

  //Crea una tarea desde el JSON
  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      status: json['status']
    );
  }

  //Con el fin de convertir el objeto a JSON, para el backend
  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status
    };
  }
}