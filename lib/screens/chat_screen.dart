import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'user_info_screen.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;

  const ChatScreen({super.key, required this.receiverId, required this.receiverName});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  String getChatId() {
    List<String> ids = [currentUserId, widget.receiverId];
    ids.sort();
    return ids.join("_");
  }

  // --- DELETE MESSAGE ---
  void _deleteMessage(String msgId) {
    FirebaseFirestore.instance.collection('chats').doc(getChatId()).collection('messages').doc(msgId).delete();
  }

  // --- EDIT MESSAGE ---
  void _editMessage(String msgId, String oldText) {
    _controller.text = oldText;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Message"),
        content: TextField(controller: _controller),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('chats').doc(getChatId()).collection('messages').doc(msgId).update({'message': _controller.text});
              _controller.clear();
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E1B48),
        title: GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => UserInfoScreen(userId: widget.receiverId, userName: widget.receiverName))),
          child: Text(widget.receiverName),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('chats').doc(getChatId()).collection('messages').orderBy('timestamp', descending: true).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
                return ListView.builder(
                  reverse: true,
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    var doc = snapshot.data!.docs[index];
                    bool isMe = doc['senderId'] == currentUserId;
                    return GestureDetector(
                      onLongPress: isMe ? () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(leading: const Icon(Icons.edit), title: const Text("Edit"), onTap: () { Navigator.pop(context); _editMessage(doc.id, doc['message']); }),
                              ListTile(leading: const Icon(Icons.delete, color: Colors.red), title: const Text("Delete"), onTap: () { Navigator.pop(context); _deleteMessage(doc.id); }),
                            ],
                          ),
                        );
                      } : null,
                      child: Align(
                        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          decoration: BoxDecoration(color: isMe ? Colors.deepPurple : Colors.grey[800], borderRadius: BorderRadius.circular(10)),
                          child: Text(doc['message'], style: const TextStyle(color: Colors.white)),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          _buildInput(),
        ],
      ),
    );
  }

  Widget _buildInput() {
    final TextEditingController msgController = TextEditingController();
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Expanded(child: TextField(controller: msgController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: "Type...", hintStyle: TextStyle(color: Colors.grey)))),
          IconButton(icon: const Icon(Icons.send, color: Colors.purpleAccent), onPressed: () {
            if (msgController.text.isNotEmpty) {
              FirebaseFirestore.instance.collection('chats').doc(getChatId()).collection('messages').add({
                'senderId': currentUserId,
                'message': msgController.text,
                'timestamp': FieldValue.serverTimestamp(),
              });
              msgController.clear();
            }
          }),
        ],
      ),
    );
  }
}