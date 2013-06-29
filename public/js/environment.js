var OnTheWay = {
  getEnv : function() {
    switch (window.location.hostname) {
      case "localhost" :
      case "127.0.0.1" :
        return "local";
        break;
      case "staging.onthewayhq.com" :
        return "staging";
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
    return 'production';
  }
};
OnTheWay.config = {
  local : {
    protocol  : 'http://',
    domain    : 'localhost:3000'
  },
  staging : {
    protocol  : 'http://',
    domain    : 'staging.onthewayhq.com'
  },
  production : {
    protocol  : 'http://',
    domain    : 'www.onthewayhq.com'
  }
};
