import 'package:uuid/uuid.dart';
import 'draft_task_attachment.dart';

class DraftTask {
  final String localId;
  final int sequenceIndex;
  final String name;
  final String? description;
  final String? machineDetails;
  final String? notes;
  final int sets;
  final String reps;
  final int? restSeconds;
  final String? tempo;
  final List<DraftTaskAttachment> attachments;

  DraftTask({
    String? localId,
    required this.sequenceIndex,
    required this.name,
    this.description,
    this.machineDetails,
    this.notes,
    required this.sets,
    required this.reps,
    this.restSeconds,
    this.tempo,
    this.attachments = const [],
  }) : localId = localId ?? const Uuid().v4();

  DraftTask copyWith({
    int? sequenceIndex,
    String? name,
    String? description,
    String? machineDetails,
    String? notes,
    int? sets,
    String? reps,
    int? restSeconds,
    String? tempo,
    List<DraftTaskAttachment>? attachments,
  }) {
    return DraftTask(
      localId: localId,
      sequenceIndex: sequenceIndex ?? this.sequenceIndex,
      name: name ?? this.name,
      description: description ?? this.description,
      machineDetails: machineDetails ?? this.machineDetails,
      notes: notes ?? this.notes,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      tempo: tempo ?? this.tempo,
      attachments: attachments ?? this.attachments,
    );
  }

  Map<String, dynamic> toJson() => {
        'sequenceIndex': sequenceIndex,
        'name': name,
        if (description != null && description!.isNotEmpty) 'description': description,
        if (machineDetails != null && machineDetails!.isNotEmpty) 'machineDetails': machineDetails,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
        'sets': sets,
        'reps': reps,
        if (restSeconds != null) 'restSeconds': restSeconds,
        if (tempo != null && tempo!.isNotEmpty) 'tempo': tempo,
        if (attachments.isNotEmpty)
          'attachments': attachments.map((a) => a.toJson()).toList(),
      };
}
