import 'dart:io';

import 'package:atmonitor/colors.dart';
import 'package:atmonitor/handlers/jobsHandle.dart';
import 'package:atmonitor/ui/partSearchDelegatesPage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class JobDoneConfirmationPage extends StatefulWidget {
  final List<DocumentSnapshot> jobs;
  final int position;

  JobDoneConfirmationPage(this.jobs, this.position);

  @override
  _JobDoneConfirmationPageState createState() =>
      _JobDoneConfirmationPageState();
}

class _JobDoneConfirmationPageState extends State<JobDoneConfirmationPage> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final scaffoldKey = GlobalKey<ScaffoldState>();
  final jobsHandle = JobsHandle();
  File pictureTaken;
  List<String> changedPartsSelected = List<String>();
  String solution = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        title: Text("Konfirmasi"),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(10.0),
              ),
              ListTile(
                title: Form(
                  key: formKey,
                  child: TextFormField(
                    onSaved: (value) {
                      solution = value;
                    },
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                        labelText: "Solusi Yang Dikerjakan:",
                        border: OutlineInputBorder()),
                    initialValue: "",
                    validator: (value) => value.isEmpty || value == ""
                        ? "Isi solusi yang dikerjakan"
                        : null,
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: EdgeInsets.all(7.0),
          ),
          Divider(),
          ListTile(
            title: Text("Suku Cadang Yang Diganti"),
            subtitle: Text("daftar suku cadang: "),
            trailing: IconButton(
              icon: Icon(
                Icons.add_circle,
                color: aBlue800,
              ),
              onPressed: () async {
                showSearch(
                        context: context, delegate: PartsSearchDelegatesPage())
                    .then((part) {
                  part == null
                      ? debugPrint("part kosong tidak terlempar")
                      : changedPartsSelected.add(part.toString());
                });
              },
            ),
          ),
          ListView.builder(
            physics: ClampingScrollPhysics(),
            shrinkWrap: true,
            itemCount: changedPartsSelected.length,
            itemBuilder: (BuildContext context, int position) {
              return ListTile(
                  title: Text(changedPartsSelected[position].toString()),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.remove_circle,
                      color: Colors.redAccent,
                    ),
                    onPressed: () {
                      setState(() {
                        changedPartsSelected.removeAt(position);
                      });
                    },
                  ));
            },
          ),
          Divider(),
          ListTile(
            title: Text("Unggah Bukti Gambar"),
            trailing: IconButton(
              icon: Icon(
                Icons.camera_alt,
                color: aBlue800,
              ),
              onPressed: () {
                takePicture(context, ImageSource.camera);
              },
            ),
            subtitle: Text("pratinjau: "),
          ),
          SizedBox(
            height: 10.0,
          ),
          pictureTaken == null
              ? Text(
                  "tidak ada gambar",
                  textAlign: TextAlign.center,
                )
              : Image.file(
                  pictureTaken,
                  height: 300.0,
                  width: MediaQuery.of(context).size.width,
                  alignment: Alignment.topCenter,
                ),
          Padding(
            padding: EdgeInsets.all(10.0),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
          icon: Icon(
            Icons.check,
            color: aBlue800,
          ),
          label: Text("Konfirmasi", style: TextStyle(color: aBlue800)),
          onPressed: () {
            if (formKey.currentState.validate()) {
              formKey.currentState.save();
              jobsHandle.finishJob(
                  widget.jobs, widget.position, pictureTaken, solution);
              formKey.currentState.reset();
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacementNamed("/acceptedjobs");
            }
          }),
    );
  }

  void takePicture(BuildContext context, ImageSource imageSource) {
    ImagePicker.pickImage(
      source: imageSource,
      maxWidth: 400.0,
    ).then((File image) {
      setState(() {
        pictureTaken = image;
      });
    });
  }
}
