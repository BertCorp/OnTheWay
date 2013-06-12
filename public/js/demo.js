  String.prototype.format = function() { a = this; for ( k in arguments ) { a = a.replace("{" + k + "}", arguments[k]); } return a; };
  window.demo = {
    'version': '1.0',
    'ga': '',
    'primaryUrl': 'http://www.onthewayhq.com',
    'url': 'http://www.onthewayhq.com',
    'exception': 'Unable to load due to either poor internet connection or some CDN\'s aren\'t as responsive as we would like them to be. Try refreshing the page :D.',
    'init': function() {},
    'col': [],
    'tests': [],
    'test': function(a, b) { if ( window[a] ) { b(); } },
    'add': function(a, b) { if (b) { this.col[a] = b; } else { this.col.push(a); } return this; },
    'load': function(a) { var self = this; if (a) { self.col[a](); } else { $.each(self.col, function(i,d) { try { d(); } catch (err) { alert(self.exception); } }); } },
    'timeStart': function(key, desc) { this.tests[key] = { 'start': new Date().getTime(), 'desc': desc }; },
    'timeEnd': function(key) { this.tests[key].elapsed = new Date().getTime(); },
    'report': function(id) { var i = 1; for ( var k in this.tests ) { var t = this.tests[k]; $(id).append('<div class="benchmark rounded"><div class="benchmark-result lt">' + (t.elapsed - t.start) + ' ms</div><div class="lt"><p class="benchmark-iteration">Benchmark case ' + i + '</p><p class="benchmark-title">' + t.desc + '</p></div></div>'); i++; }; }
  };

  demo.init();
