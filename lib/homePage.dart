import 'package:deep_blue_project/pre_analytics.dart';
import 'package:flutter/material.dart' hide CarouselController;
import 'package:carousel_slider/carousel_slider.dart';

import 'activity.dart';
import 'analytics.dart';
import 'fridge.dart';
import 'menuPage.dart';
import 'profile.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}


class _HomePageState extends State<HomePage> {
  final int _selectedIndex = 0;
  int _current = 0;
  final int _current2= 0;
  int current2 = 0;
  final List<String> imgList = [
    'assets/expiration.png',
    'assets/recipe.png',
    'assets/analytics.png',
    'assets/donate.png',
    'assets/environment.png',
  ];// To track the selected tab
  final List<String> _carouselTexts = [
    "Tired of throwing out food? We'll help you track it!",
    "Leftovers? No problem! We've got delicious recipes for you.",
        "Predicting demand. Preventing waste. Profiting together.",
    "Give back while reducing waste. Donate to local charities.",
        "Every bite counts. Let's save our planet, one meal at a time."
  ];
  final ScrollController _scrollController = ScrollController();

  final List<Testimonial> testimonials = [
    Testimonial(
      imagePath: 'assets/david.png',

      text: "I used to throw out so much food because I forgot about expiration dates. This app's reminder system is a lifesaver! Now I'm actually using up what I buy. \n - John D., Home "
    ),
    Testimonial(
      imagePath: 'assets/sarah.png',
      text: "I was always stumped on what to do with leftovers. This app provides amazing recipe ideas, and now I'm actually excited to use them up! \n - Sarah J., Busy Professional "
    ),
    Testimonial(
      imagePath: 'assets/chef.png',
      text:  "Since implementing this app, our food waste has significantly decreased. We're saving money and reducing our environmental impact. It's a win-win!  \n - Chef David"
    ),
    Testimonial(
      imagePath: 'assets/emily.png',
      text: "It feels great knowing that any surplus food I can't use is going to a good cause. This app makes it so easy to connect with local charities. \n - Emily S., Community Member"
    ),
    Testimonial(
      imagePath: 'assets/eco.png',
      text: "This app makes it easy to make a difference. I feel good knowing that I'm contributing to a more sustainable future, one meal at a time. \n  - Eco-conscious Consumer"
    ),
  ];




  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hero Section
            Stack(
              children: [
                Image.asset(
                  'assets/img.png', // Replace with your image path
                  height: 300,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Container(
                  height: 300,
                  color: Colors.black.withOpacity(0.5),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    'Reduce Food Waste,\nSave Money, Save the Planet',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center, // Center the column
                children: [
                  SizedBox(height: 15,),
                  Text(
                    'Our Mission',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'To empower individuals to reduce food waste, save money, and contribute to a more sustainable future.',
                    textAlign: TextAlign.center, // Center the text
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      _scrollController.animateTo(
                        _scrollController.position.maxScrollExtent,
                        duration: Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: Text('Know more'),
                  ),
                  SizedBox(height: 10,),

                  CarouselSlider(
                    items: imgList
                        .map((item) => Stack(
                      alignment: Alignment.center, // Center the text within the image
                      children: [
                        Image.asset(
                          item,
                          fit: BoxFit.cover,
                          width: double.infinity,

                        ),
                        Positioned(
                          bottom: 16.0,
                          left: 0, // Align text to the left
                          right: 0, // Align text to the right
                          child: Container(
                            color: Colors.black.withOpacity(0.5), // Add a semi-transparent background
                            padding: EdgeInsets.symmetric(horizontal: 16.0), // Add padding to the text container
                            child: Text(
                              _carouselTexts[imgList.indexOf(item)], // Get text based on image index
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16.0,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center, // Center the text horizontally
                            ),
                          ),
                        ),
                      ],
                    )).toList(),
                    options: CarouselOptions(
                      height: MediaQuery.of(context).size.height * 0.4,
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _current = index;
                        });
                      },
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imgList.map((url) {
                      int index = imgList.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index
                              ? Colors.grey
                              : Colors.grey.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ),
                  SizedBox(height: 20,),
                  CarouselSlider(
                    items: testimonials.map((testimonial) =>
                        Container(
                          padding: EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: AssetImage(testimonial.imagePath),
                              ),
                              SizedBox(height: 20),
                              Text(
                                testimonial.text,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[700],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ).toList(),
                    options: CarouselOptions(
                      height: 300, // Adjust height as needed
                      autoPlay: true,
                      autoPlayInterval: Duration(seconds: 3),
                      autoPlayAnimationDuration: Duration(milliseconds: 800),
                      autoPlayCurve: Curves.fastOutSlowIn,
                      enlargeCenterPage: true,
                      onPageChanged: (index, reason) => setState(() => current2 = index),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imgList.map((url) {
                      int index = imgList.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: current2 == index
                              ? Colors.grey
                              : Colors.grey.withOpacity(0.4),
                        ),
                      );
                    }).toList(),
                  ),

                ],
              ),
            ),


          ],
        ),
      ),

    );
  }
}
class Testimonial {
  final String imagePath;
  final String text;

  Testimonial({required this.imagePath, required this.text});
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0; // Default selected tab is Home

  // List of pages for each tab
  final List<Widget> _pages = [
    HomePage(),        // Replace with your HomePage widget
    ProfilePage(),     // Placeholder for DashboardPage if not implemented
    Placeholder(),     // Placeholder for FoodPage if not implemented
    Placeholder(),     // Placeholder for AnalyticsPage if not implemented
    MyFridge(),        // Replace with your MyFridgePage widget
  ];

  // Function to handle bottom navigation bar taps
  void _onItemTapped(int index) {
    setState(() {
      if (index == 2) {
        BottomSheetOptions.show(context); // Show the bottom sheet
      }
      else if(index ==3){
        BottomSheetOptions2.show(context);
      }
      else {
        _selectedIndex = index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MenuPage()),
                );
              },
              child: const Icon(Icons.menu, color: Colors.black87),
            ),
            const SizedBox(width: 20),
            const Text(
              'EcoBite',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            const Icon(Icons.notifications, color: Colors.black87),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.handshake),
            label: 'Food',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_graph),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.kitchen),
            label: 'My Fridge',
          ),
        ],
        selectedItemColor: Colors.black87,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}





