import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'User Outlet Details',
      theme: ThemeData(
      ),
      home: UserOutlet(), // Updated class name to UserOutlet
    );
  }
}

class UserOutlet extends StatelessWidget { // Updated class name to UserOutlet
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Outlet Details'),
        backgroundColor: const Color.fromARGB(255, 245, 184, 93), // AppBar color
      ),
      
      body:Stack(
        children: [
          Container(
         decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color.fromARGB(255, 245, 184, 93),
                  const Color.fromARGB(255, 233, 211, 88),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
       child: 
       SingleChildScrollView(
       
        
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            
            
          
            Text(
              'Outlet Name: Best Outlet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Address: 123 Main Street, Cityville',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: (123) 456-7890',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Button for Stock Details Page (No hyperlink or navigator needed)
            ElevatedButton(
              onPressed: () {},
                // Placeholder for Stock Details Page route
                // In your actual code, you would define a route to navigate to stock details.
              child: Text(
                'View Stock Details',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                 // Button color
              ),
            ),
            SizedBox(height: 20),
            // Display stock summary or any other relevant info
           Text(
              'Outlet Name: Best Outlet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Address: 123 Main Street, Cityville',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: (123) 456-7890',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Button for Stock Details Page (No hyperlink or navigator needed)
            ElevatedButton(
              onPressed: () {},
                // Placeholder for Stock Details Page route
                // In your actual code, you would define a route to navigate to stock details.
              child: Text(
                'View Stock Details',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                 // Button color
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Outlet Name: Best Outlet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Address: 123 Main Street, Cityville',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: (123) 456-7890',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Button for Stock Details Page (No hyperlink or navigator needed)
            ElevatedButton(
              onPressed: () {
                // Placeholder for Stock Details Page route
                // In your actual code, you would define a route to navigate to stock details.
              },
              child: Text(
                'View Stock Details',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                 // Button color
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Outlet Name: Best Outlet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Address: 123 Main Street, Cityville',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: (123) 456-7890',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Button for Stock Details Page (No hyperlink or navigator needed)
            ElevatedButton(
              onPressed: () {
                // Placeholder for Stock Details Page route
                // In your actual code, you would define a route to navigate to stock details.
               
              },
              child: Text(
                'View Stock Details',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                 // Button color
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Outlet Name: Best Outlet',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Address: 123 Main Street, Cityville',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Phone: (123) 456-7890',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            // Button for Stock Details Page (No hyperlink or navigator needed)
            ElevatedButton(
              onPressed: () {
                // Placeholder for Stock Details Page route
                // In your actual code, you would define a route to navigate to stock details.
  },
              child: Text(
                'View Stock Details',
                style: TextStyle(fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                 // Button color
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    )]));
  }
}



