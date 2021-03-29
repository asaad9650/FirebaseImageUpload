import 'dart:html';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase/firebase.dart' as fb;
import 'package:universal_html/html.dart' as htmls;

class ImageSelect extends StatefulWidget {
  @override
  _ImageSelectState createState() => _ImageSelectState();
}

class _ImageSelectState extends State<ImageSelect> {
  var uploadedImage, option1Text;
  var fileName = [];
  fb.UploadTask _uploadTask;

  _startFilePicker() async {
    InputElement uploadInput = FileUploadInputElement();
    uploadInput.accept = ".png";
    uploadInput.multiple = true;
    uploadInput.click();
    uploadInput.onChange.listen((e) {
      // read file content as dataURL
      final files = uploadInput.files;
      if (files.length == 1) {
        final file = files[0];
        FileReader reader = FileReader();

        reader.onLoadEnd.listen((e) {
          print('loaded: ${file.name}');
          setState(() {
            fileName.add(file.name);
            uploadedImage = reader.result;
          });
        });

        reader.onError.listen((fileEvent) {
          setState(() {
            option1Text = "Some Error occured while reading the file";
          });
        });

        reader.readAsArrayBuffer(file);
        // uploadImageFile(file, "name");
        uploadToFirebase(file);
        // print(reader.readAsText(file));

      } else {
        int i = files.length;
        print(i);

        for (i = 0; i < files.length; i++) {
          setState(() {
            fileName.add(files[i].name.toString());
          });

          // fileName.add(files[i].name);
          print(files[i].name);
          print(files[i].relativePath);
          // uploadImageFile( files , (files[i].name))

          final file = files[i];
          FileReader reader = FileReader();
          reader.readAsArrayBuffer(file);
        }
      }
    });
  }

  Future<Uri> uploadImageFile(htmls.File image, String imageName) async {
    fb.StorageReference storageRef = fb.storage().ref('images/$imageName');
    fb.UploadTaskSnapshot uploadTaskSnapshot =
        await storageRef.put(image).future;

    Uri imageUri = await uploadTaskSnapshot.ref.getDownloadURL();
    return imageUri;
  }

  uploadToFirebase(File imageFile) async {
    final filePath = 'images/${DateTime.now()}.png';
    setState(() {
      _uploadTask = fb
          .storage()
          .refFromURL('gs://upload-60166.appspot.com')
          .child(filePath)
          .put(imageFile);
    });
  }
  //just plans not products.
  //developed in flutter and has some issues.
  //firebase as a backend
  //flashfood.
  //Amandeep is a Director of the company..
  //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: ElevatedButton(
                onPressed: () {
                  // pickFiles();
                  _startFilePicker();
                },
                child: Text("Select Image"),
              ),
            ),
            if (fileName != null) Text(fileName.toString()),
          ],
        ),
      ),
    );
  }
}
