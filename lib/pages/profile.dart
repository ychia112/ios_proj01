import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:ios_proj01/providers/metamask_provider.dart';
import 'package:ios_proj01/widgets/post_viewing.dart';
import 'package:provider/provider.dart';
import 'home.dart';
import '../utils/mood.dart';
import 'package:google_fonts/google_fonts.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({Key? key}) : super(key: key);

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final double coverHeight = 280;
  final double profileHeight = 120;

  Future<List<dynamic>> getUserPosts(BuildContext context) async {
    final url = Uri.parse("${dotenv.env['backend_address']}/api/get-all-posts-owned-by?owner=${context.read<MetaMask>().session.accounts[0]}");
    http.Response res = await http.get(url);
    return jsonDecode(res.body);
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: false,
          automaticallyImplyLeading: false,
          elevation: 0,
          backgroundColor: Colors.transparent,
          // leading:
          title: Text(
            'Profile',
            style: GoogleFonts.abrilFatface(
                textStyle: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.black
                )),
          ),
        ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(height: 12,),
          const SizedBox(height: 5,),
          const PostViewingWidget(),
        ],
      ),
    );
  }

  Widget buildContent(BuildContext context) => Column(
    children: [
      const SizedBox(height: 8),
      Text(
        '@'+context.read<MetaMask>().session.accounts[0],
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 10,),
    ],
  );

  Widget buildProfileImage() => CircleAvatar(
    radius: profileHeight / 2,
    backgroundColor: Colors.grey.shade800,
    backgroundImage: const AssetImage('assets/images/2.jpg')
  );

  Widget buildPosts(_posts) => FutureBuilder<List<dynamic>>(
    future: _posts,
    builder: (context, snapshot) {
      if(snapshot.hasData){
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const MyStatefulWidget(),
              Container(
                height: MediaQuery.of(context).size.height-260,
                width: MediaQuery.of(context).size.width,
                color: Colors.transparent,
                child: ListView.separated(
                  itemCount: snapshot.data!.length,
                  padding: const EdgeInsets.only(top:5.0,bottom:15.0),
                  separatorBuilder: (BuildContext context,int index)=>
                  const Divider(height: 16,color: Colors.transparent),
                  itemBuilder: (BuildContext context, int index) {
                    if (index == 0){
                      return Column(
                        children: [
                          buildProfileImage(),
                          buildContent(context),

                        ],
                      );
                    }
                    index = snapshot.data!.length - 1 - index;
                    return Container(
                      alignment: Alignment.center,
                      // tileColor: _items[index].isOdd ? oddItemColor : evenItemColor,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(24.0),
                        color:  Colors.grey.shade300,
                      ),
                      child:
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Row(
                            children:[
                              const Padding(padding: EdgeInsets.only(top:60.0,left: 10)),
                              ClipOval(
                                child:
                                Image.asset('assets/images/2.jpg',width: 50,height: 50,fit: BoxFit.cover,)
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Center(
                                child: Container(
                                  alignment: Alignment.center,
                                  width: MediaQuery.of(context).size.width-24,
                                  constraints: const BoxConstraints(
                                      maxHeight: 250, minHeight: 200
                                  ),//should be more precise
                                  decoration: BoxDecoration(
                                    //borderRadius: BorderRadius.circular(24.0),
                                    color:  Colors.grey.shade200,),
                                  child:
                                  Text(
                                      snapshot.data![index]['context'], textAlign: TextAlign.center,
                                      maxLines: 10),
                                )
                              )
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                width: 50,
                                height: 40,
                                //color: Colors.black26,
                                child: RawMaterialButton(
                                  onPressed: () {},
                                  // fillColor: Colors.transparent,
                                  highlightColor:Colors.transparent,
                                  splashColor:Colors.transparent,
                                  hoverColor:Colors.transparent,
                                  shape: const CircleBorder(),
                                  child: Text(
                                    moodEmoji[snapshot.data![index]['mood']], // Replace with desired emoji//happy
                                    style: const TextStyle(fontSize: 20.0, color: Colors.white),
                                  ),
                                )
                              ),
                              const Spacer(),
                              if(snapshot.data![index].containsKey('datetime'))
                                Text(DisplayDateTime(snapshot.data![index]['datetime'])),
                              const SizedBox(width: 10,)
                            ],
                          ),
                        ],
                      )
                    );
                  }
                ),
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: 85,
                color: Colors.transparent,
              )
            ]
          )
        );
      }
      else{
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const <Widget>[
              SizedBox(
                width: 60,
                height: 60,
                child: CircularProgressIndicator(),
              ),
              Padding(
                padding: EdgeInsets.only(top: 16),
                child: Text('Awaiting result...'),
              ),
            ],
          ),
        );
      }
    },
  );

  String DisplayDateTime(String dateTimeString){
    DateTime postDateTime = DateTime.parse(dateTimeString);
    Duration duration = DateTime.now().difference(postDateTime);
    String output = postDateTime.toLocal().toString().substring(0, 16) + ' (';
    if(duration.inDays != 0){
      output += '${duration.inDays}';
      output += (duration.inDays == 1? ' day ago': ' days ago');
    }
    else if(duration.inHours != 0){
      output += '${duration.inHours}';
      output += (duration.inHours == 1? ' hour ago': ' hours ago');
    }
    else {
      output += '${duration.inMinutes}';
      output += (duration.inMinutes <= 1? ' min ago': ' mins ago');
    }
    output += ')';
    return output;
  }
}