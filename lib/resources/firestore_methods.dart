import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/models/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //upload post
  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImage,
  ) async {
    String res = "Some error occurred";
    
    try{
      String photoUrl = await StorageMethods().uploadImageToStorage("posts", file, true);

      String postId = Uuid().v1();
      Post post = Post(
        description: description,
        uid: uid,
        username:username,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl:photoUrl,
        profImage:profImage,
        likes:[],
      );

      _firestore.collection('posts').doc(postId).set(
        post.toJson(),
      );
      res = 'success';
    }catch(err){
      res = err.toString();
    }
    return res;
  }
  Future<String> likePost(String postId, String uid, List likes) async {
    String res = "Some error occurred";
    try{
      if(likes.contains(uid)){
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      }else{
        await _firestore.collection('posts').doc(postId).update({
          'likes':FieldValue.arrayUnion([uid])
        });
      }
      res = 'success';
    }catch(e){
      res = e.toString();
    }
    return res;
  }
  Future<String> postComment(String postId, String text, String uid, String name, String profilePic) async{
    String res = "Some error occurred";
    try{
      if(text.isNotEmpty){
        String commentId = const Uuid().v1();
        await _firestore.collection('posts').doc(postId).collection('comments').doc(commentId).set({
          'profilePic':profilePic,
          'name':name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });
      }else{
        res = 'Please enter text';
      }
    }catch(e){
      res = e.toString();
    }
    return res;

  }

  // deleting post

  Future<String> deletePost(String postId) async{
    String res = "Some error occurred";
    try{
      await _firestore.collection('posts').doc(postId).delete();
      res = 'success';
    }catch(err){
      res = err.toString();
    }
    return res;
  }

  Future<String> followUser(
    String uid,
    String followId,
  ) async{
        String res = "Some error occurred";

    try{
      DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];
      if(following.contains(followId)){
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });
      }else{
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });
      }
      res = 'success';
    }
    catch(e){
      res = e.toString();
    }
    return res;
  }

}
