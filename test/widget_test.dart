import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ranes_labact6/main.dart';
import 'package:ranes_labact6/demo_auth.dart';
import 'package:ranes_labact6/login_screen.dart';
import 'package:ranes_labact6/main_screen.dart';
import 'package:ranes_labact6/register_screen.dart';
import 'package:ranes_labact6/social_media/create_post_sheet.dart';
import 'package:ranes_labact6/social_media/post_card.dart';

// Builds the app on a tall screen so list items are laid out, then settles.
Future<void> pumpApp(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 1800));
  await tester.pumpWidget(const StudentApp());
  await tester.pumpAndSettle();
}

// Logs in with the default admin credentials.
Future<void> loginAdmin(WidgetTester tester) async {
  await tester.enterText(find.byType(TextFormField).at(0), 'admin');
  await tester.enterText(find.byType(TextFormField).at(1), 'admin123');
  await tester.tap(find.byType(ElevatedButton).first);
  await tester.pumpAndSettle();
}

// Opens the Social Media tab from the bottom navigation bar.
Future<void> openSocialMedia(WidgetTester tester) async {
  final navBar = find.byType(NavigationBar);
  await tester.tap(find.descendant(of: navBar, matching: find.text('Social Media')));
  await tester.pumpAndSettle();
}

// Opens the create post sheet, fills both fields, and submits.
Future<void> createPost(WidgetTester tester,
    {required String caption, required String imageUrl}) async {
  await tester.tap(find.byIcon(Icons.add));
  await tester.pumpAndSettle();

  final sheet = find.byType(CreatePostSheet);
  final fields = find.descendant(of: sheet, matching: find.byType(TextField));
  await tester.enterText(fields.at(0), caption);
  await tester.enterText(fields.at(1), imageUrl);
  await tester.tap(find.descendant(of: sheet, matching: find.byType(ElevatedButton)).first);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() {
    DemoAuth.registeredUsername = null;
    DemoAuth.registeredPassword = null;
    DemoAuth.currentUsername = null;
  });

  testWidgets('Login with admin / admin123 opens MainScreen; Social Media tab shows two sample posts',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await loginAdmin(tester);
    expect(find.byType(MainScreen), findsOneWidget);

    await openSocialMedia(tester);
    expect(find.text('JohnDoe'), findsOneWidget);
    expect(find.text('JaneSmith'), findsOneWidget);
  });

  testWidgets('Create Post with empty fields shows error; invalid URL shows error',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await loginAdmin(tester);
    await openSocialMedia(tester);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    final sheet = find.byType(CreatePostSheet);

    // Submit with both fields empty.
    await tester.tap(
        find.descendant(of: sheet, matching: find.byType(ElevatedButton)).first);
    await tester.pumpAndSettle();
    expect(find.text('Complete both fields before submitting!'), findsWidgets);

    // Enter caption but an invalid URL.
    final fields = find.descendant(of: sheet, matching: find.byType(TextField));
    await tester.enterText(fields.at(0), 'Test caption');
    await tester.enterText(fields.at(1), 'abc');
    await tester.tap(
        find.descendant(of: sheet, matching: find.byType(ElevatedButton)).first);
    await tester.pumpAndSettle();
    expect(find.text('Enter a valid HTTP or HTTPS image URL.'), findsWidgets);
  });

  testWidgets('A valid post appears at the TOP of the feed',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await loginAdmin(tester);
    await openSocialMedia(tester);

    await createPost(tester,
        caption: 'My first Flutter social media post!',
        imageUrl: 'https://picsum.photos/id/1/600/400');

    final firstCard = find.byType(PostCard).at(0);
    expect(
        find.descendant(
            of: firstCard, matching: find.text('My first Flutter social media post!')),
        findsOneWidget);
    expect(find.descendant(of: firstCard, matching: find.text('admin')),
        findsOneWidget);
  });

  testWidgets('Tapping Like changes Like to Liked and a second tap changes it back',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await loginAdmin(tester);
    await openSocialMedia(tester);

    await tester.tap(find.text('Like').first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);
    expect(find.text('Like'), findsOneWidget);

    await tester.tap(find.text('Liked').first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsNothing);
    expect(find.text('Like'), findsWidgets);
  });

  testWidgets('A non-empty comment appears and count changes; blank comment adds nothing',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await loginAdmin(tester);
    await openSocialMedia(tester);

    final firstCard = find.byType(PostCard).at(0);
    final commentField =
        find.descendant(of: firstCard, matching: find.byType(TextField)).first;
    final sendButton =
        find.descendant(of: firstCard, matching: find.byType(IconButton)).first;

    expect(find.text('0 Comments'), findsWidgets);

    await tester.enterText(commentField, 'Great post!');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text('Great post!'), findsOneWidget);
    expect(find.descendant(of: firstCard, matching: find.text('1 Comments')),
        findsOneWidget);

    // Blank comment adds nothing.
    await tester.tap(sendButton);
    await tester.pumpAndSettle();
    expect(find.descendant(of: firstCard, matching: find.text('1 Comments')),
        findsOneWidget);
  });

  testWidgets('Like a sample post, then create another post; original keeps liked state',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await loginAdmin(tester);
    await openSocialMedia(tester);

    await tester.tap(find.text('Like').first);
    await tester.pumpAndSettle();
    expect(find.text('Liked'), findsOneWidget);

    await createPost(tester,
        caption: 'Another post', imageUrl: 'https://picsum.photos/id/2/600/400');

    // Verify the new post was inserted at the top.
    expect(find.text('Another post'), findsOneWidget);
    expect(find.byType(PostCard), findsNWidgets(3));

    // Original post keeps its liked state via ObjectKey.
    expect(find.text('Liked'), findsOneWidget);
    expect(find.text('Like'), findsWidgets);
  });

  testWidgets('Switch to Home and back to Social Media; posts, likes, and comments remain',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await loginAdmin(tester);
    await openSocialMedia(tester);

    final firstCard = find.byType(PostCard).at(0);
    final commentField =
        find.descendant(of: firstCard, matching: find.byType(TextField)).first;
    final sendButton =
        find.descendant(of: firstCard, matching: find.byType(IconButton)).first;

    await tester.tap(find.text('Like').first);
    await tester.enterText(commentField, 'Nice!');
    await tester.tap(sendButton);
    await tester.pumpAndSettle();

    expect(find.text('Liked'), findsOneWidget);
    expect(find.text('Nice!'), findsOneWidget);

    final navBar = find.byType(NavigationBar);
    await tester.tap(find.descendant(of: navBar, matching: find.text('Home')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Student!'), findsOneWidget);

    await tester.tap(find.descendant(of: navBar, matching: find.text('Social Media')));
    await tester.pumpAndSettle();

    expect(find.text('Liked'), findsOneWidget);
    expect(find.text('Nice!'), findsOneWidget);
  });

  testWidgets('Logout from Home returns to the Login screen',
      (WidgetTester tester) async {
    await pumpApp(tester);
    await loginAdmin(tester);

    final navBar = find.byType(NavigationBar);
    await tester.tap(find.descendant(of: navBar, matching: find.text('Home')));
    await tester.pumpAndSettle();
    expect(find.text('Welcome, Student!'), findsOneWidget);

    await tester.tap(find.byTooltip('Logout'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.byType(MainScreen), findsNothing);
  });

  testWidgets('Register a new account, log in, create a post; post shows registered username',
      (WidgetTester tester) async {
    await pumpApp(tester);

    await tester.tap(find.text("Don't have an account? Register"));
    await tester.pumpAndSettle();
    expect(find.byType(RegisterScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'student');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.enterText(find.byType(TextFormField).at(2), 'password123');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();
    expect(find.text('Registration successful! You can now log in.'),
        findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'student');
    await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    await tester.tap(find.byType(ElevatedButton).first);
    await tester.pumpAndSettle();
    expect(find.byType(MainScreen), findsOneWidget);

    await openSocialMedia(tester);
    await createPost(tester,
        caption: 'Hello from student',
        imageUrl: 'https://picsum.photos/id/3/600/400');

    final firstCard = find.byType(PostCard).at(0);
    expect(find.descendant(of: firstCard, matching: find.text('student')),
        findsOneWidget);
  });
}
