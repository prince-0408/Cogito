# Cogito - AI-Powered Task Manager & Scheduler

Cogito is an advanced AI-powered task manager that helps users organize, track, and optimize their workflow using OpenAI-driven task suggestions, heatmap tracking, and intelligent scheduling.

## Features

- **Built-in OpenAI Integration**: Real AI-powered task suggestions and insights using OpenAI's GPT models
- **Prompt-Based Task Creation**: Create tasks using natural language prompts and AI processing
- **Natural Language Processing**: Create tasks using natural language input
- **Heatmap Calendar**: Visualize your productivity with an intuitive heatmap calendar
- **Task Insights & Analytics**: Understand your productivity patterns with AI-generated insights
- **Smart Categorization**: Automatically categorize tasks based on content
- **Priority Management**: Organize tasks by priority levels (Low, Medium, High, Urgent)
- **Notification System**: Get reminders for upcoming tasks with proper permission handling
- **Dark Mode Support**: Customize your experience with light and dark themes

## Technical Details

- **Architecture**: MVVM (Model-View-ViewModel)
- **UI Framework**: SwiftUI
- **Data Persistence**: CoreData
- **Reactive Programming**: Combine
- **Data Visualization**: Swift Charts
- **AI Integration**: OpenAI API for natural language processing and task suggestions
- **Notifications**: UNUserNotificationCenter for task reminders

## Getting Started

1. Clone the repository
2. Open the project in Xcode
3. Build and run on a simulator or device

## Project Structure

The project follows a clean MVVM architecture with the following components:

- **Models**: Data structures for tasks, AI suggestions, and calendar data
- **ViewModels**: Business logic for tasks, AI processing, and heatmap visualization
- **Views**: UI components organized by feature (Home, Calendar, Insights, Settings)
- **Services**: OpenAI integration, AI processing, and data management
- **CoreData**: Local storage for tasks and user preferences
- **Utils**: Helper extensions and constants

## OpenAI Integration

Cogito uses OpenAI's GPT models to provide intelligent task suggestions, insights, and natural language processing. The app comes with a built-in API key, so users don't need to provide their own.

## Requirements

- iOS 15.0+
- Xcode 13.0+
- Swift 5.5+

## License

This project is licensed under the MIT License - see the LICENSE file for details.

