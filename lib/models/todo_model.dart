class ToDo {
  String todoId;
  String text;
  bool checked;

  ToDo(this.todoId, this.text, this.checked);

  ToDo.fromJson(Map<String, dynamic> json)
      : todoId = json['todoId'],
        text = json['text'],
        checked = json['checked'] ?? '';

  Map<String, dynamic> toJson() => {
        'todoId': todoId,
        'text': text,
        'checked': checked,
      };
}
