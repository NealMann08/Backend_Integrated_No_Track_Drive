/*
 * API Configuration
 *
 * This file stores the server URL for all backend API calls.
 * I kept it separate so it's easy to switch between development
 * and production servers without hunting through the codebase.
 */

class AppConfig {
  // AWS API Gateway endpoint for all backend services
  static String server = 'https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com';

  // Allows changing the server at runtime if needed (useful for testing)
  static void setServer(String newServer) {
    server = newServer;
  }
}
