// Copyright 2019 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// ignore_for_file: public_member_api_docs

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:my_image_picker/my_image_picker.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Picker Demo',
      home: MyHomePage(title: 'Image Picker Example'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _path;
  File _imageFile;
  void _tapSelectCameraImage() async{
    String path = await MyImagePicker.selectCameraImage();
    print(path);
    setState(() {
      _path = path;
      _imageFile = new File(path);
    });
  }

  void _tapSelectAlbumImage() async{
    String path = await MyImagePicker.selectAlbumImage();
    print(path);
    setState(() {
      _path = path;
      _imageFile = new File(path);
    });
  }

  void _tapCircleCrop() async{
    String path = await MyImagePicker.circleCrop();
    print(path);
    setState(() {
      _path = path;
      _imageFile = new File(path);
    });
  }

  Widget _previewImage() {
    return _path == null ? Text("没有图片") : Image.file(_imageFile);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Text("${_path}",
            textAlign: TextAlign.center,
          ),
          _previewImage(),
          FloatingActionButton(
            onPressed: () {
              _tapSelectAlbumImage();
            },
            heroTag: 'image0',
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo_library),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _tapSelectCameraImage();
              },
              heroTag: 'image1',
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () {
                _tapCircleCrop();
              },
              heroTag: 'image2',
              tooltip: 'Circle crop',
              child: const Icon(Icons.add_circle),
            ),
          ),
        ],
      ),
    );
  }
}
