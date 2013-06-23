var OnTheWay = {
  getEnv : function() {
    switch (window.location.hostname) {
      case "localhost" :
      case "127.0.0.1" :
        return "local";
        break;
      case "www.onthewayhq.com" :
      case "onthewayhq.com" :
      case "www.otwhq.com" :
      case "otwhq.com" :
      case "www.otwhq.co" :
      case "otwhq.co" :
        return "production";
        break;
    }
    return 'unknown';
  }
};
OnTheWay.config = {
  local : {
    protocol  : 'http://',
    domain    : 'localhost:3000'
  },
  production : {
    protocol  : 'http://',
    domain    : 'www.onthewayhq.com'
  }
};
