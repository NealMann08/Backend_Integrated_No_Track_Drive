class AppConfig {
  //original api lin
  static String server = 'https://j16exqx7n5.execute-api.us-east-1.amazonaws.com/ntdapi'; // Default to localhost
  
  //neal api link
  //  static String server = 'https://m9yn8bsm3k.execute-api.us-west-1.amazonaws.com';


  static void setServer(String newServer) {
    server = newServer;
  }
}