{
  async = {
    dependencies = ["console" "fiber-annotation" "io-event"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02s99xxqgy7arxnfh19irk55is4mr4g4aik36ybsjqxz7mrq9y9l";
      type = "gem";
    };
    version = "2.46.0";
  };
  async-bus = {
    dependencies = ["async" "io-endpoint" "io-stream" "msgpack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16vmnzd2bsqliwrmi6cwr1cnxcwjpw5cdfafia92whp80adlbhr3";
      type = "gem";
    };
    version = "0.4.0";
  };
  async-container = {
    dependencies = ["async"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "127wzwpm288qbraqpqv4ba1rr438hdxksiigc176h3c7a62rsivi";
      type = "gem";
    };
    version = "0.38.0";
  };
  async-http = {
    dependencies = ["async" "async-pool" "io-endpoint" "io-stream" "protocol-http" "protocol-http1" "protocol-http2" "protocol-url"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0slh4q4blfifw7smyahrp8c5623p3pass2ifpigvwqfgsmlij6am";
      type = "gem";
    };
    version = "0.105.0";
  };
  async-pool = {
    dependencies = ["async"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01l5yna12l7qcmwmr0mvkkj241qh0w9vzl1fmd6p1g94q0ylk02m";
      type = "gem";
    };
    version = "0.12.0";
  };
  async-service = {
    dependencies = ["async" "async-container" "string-format"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ldnryz9f30ay63zlsfsc5dkwianf7ayq30m95jxzpcq51fdgnbi";
      type = "gem";
    };
    version = "0.25.0";
  };
  async-service-supervisor = {
    dependencies = ["async" "async-bus" "async-service" "async-utilization" "io-endpoint" "memory" "memory-leak" "process-metrics"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xcmgpiha1sz1cxkgv4gns082qd87k707p275xz9x4pyf9n9jp7n";
      type = "gem";
    };
    version = "0.21.0";
  };
  async-utilization = {
    dependencies = ["console"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10arz5049914z7il2qqqi16wcn7039d8rkvhgz5wpv899rilghwn";
      type = "gem";
    };
    version = "0.5.0";
  };
  bake = {
    dependencies = ["bigdecimal" "samovar"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0scqyjxfk1jk1f8ssn19miqmskdv4zz3dg6y4y409p5d4rmdqyx4";
      type = "gem";
    };
    version = "0.25.0";
  };
  base64 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yx9yn47a8lkfcjmigk79fykxvr80r4m1i35q82sxzynpbm7lcr7";
      type = "gem";
    };
    version = "0.3.0";
  };
  benchmark-ips = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0n9dh7yxr84k63h6l8x6mpls0wfxrpxw6kqpikvclphhqvrsk887";
      type = "gem";
    };
    version = "2.15.1";
  };
  bigdecimal = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0rng45p4vc3f6nac44cnylwch7rj4zsff3icdz6c7garwpjy3sv1";
      type = "gem";
    };
    version = "4.1.3";
  };
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qfi2ns3zwkgq616fc127xiqhan7g7m7gqpwriwcr34nds1vxwdj";
      type = "gem";
    };
    version = "1.3.8";
  };
  console = {
    dependencies = ["fiber-annotation" "fiber-local" "json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pnm9bs24jdbhsd8wjif37y8hfcbki9rwbc3dfzfk58f2dcjzf1m";
      type = "gem";
    };
    version = "1.38.0";
  };
  dry-configurable = {
    dependencies = ["dry-core" "zeitwerk"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kkk3fs22ndslgihxwm6rwr0y03rvccljmhz6vpm65q87iginpg3";
      type = "gem";
    };
    version = "1.4.0";
  };
  dry-core = {
    dependencies = ["concurrent-ruby" "logger" "zeitwerk"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18cn9s2p7cbgacy0z41h3sf9jvl75vjfmvj774apyffzi3dagi8c";
      type = "gem";
    };
    version = "1.2.0";
  };
  fiber-annotation = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00vcmynyvhny8n4p799rrhcx0m033hivy0s1gn30ix8rs7qsvgvs";
      type = "gem";
    };
    version = "0.2.0";
  };
  fiber-local = {
    dependencies = ["fiber-storage"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01lz929qf3xa90vra1ai1kh059kf2c8xarfy6xbv1f8g457zk1f8";
      type = "gem";
    };
    version = "1.1.0";
  };
  fiber-storage = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1qa0j9qjwav9xb0n3isx0rbh0942xrfback392n6vs8bidnmp3pl";
      type = "gem";
    };
    version = "1.0.1";
  };
  io-endpoint = {
    dependencies = ["openssl"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0y55bjpd4wfcykyp0vshvbgyp5838qdndxzr4pz5gg3qkbzawyjl";
      type = "gem";
    };
    version = "0.19.0";
  };
  io-event = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "000nbrgd950yx5hjk42lbzbhhcjgq4rg613652wg2aaazv759l0d";
      type = "gem";
    };
    version = "1.22.1";
  };
  io-stream = {
    dependencies = ["openssl"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kgim30xjghz4z6047nkc5sy8casmmlqvzqzfsycnv06l8zb3n87";
      type = "gem";
    };
    version = "0.14.0";
  };
  json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0shwgjqbj856mb6m9kgkpy08nhym2gdvc2yaprlimfmky9y3n78z";
      type = "gem";
    };
    version = "2.21.2";
  };
  logger = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00q2zznygpbls8asz5knjvvj2brr3ghmqxgr83xnrdj4rk3xwvhr";
      type = "gem";
    };
    version = "1.7.0";
  };
  memory = {
    dependencies = ["bake" "console" "msgpack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1d44nsmlg7dc648icdcxs71rwas9pzmh5nlilikmd3pc9kc18skq";
      type = "gem";
    };
    version = "0.12.0";
  };
  memory-leak = {
    dependencies = ["process-metrics"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0i8s03wk2m0brkkcnn0w7s4bbrs8b3x1h4chxgz57hdbsr778x38";
      type = "gem";
    };
    version = "0.10.3";
  };
  msgpack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fhpfl9fznn6wi39xh05crswigywvyiw3rn0cbjf7prmgfm9whcp";
      type = "gem";
    };
    version = "1.8.5";
  };
  mustermann = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "163i29mdcr1h0nximk3d51a1fgp7vz3sfasn8p1rjm2d4g3p0qac";
      type = "gem";
    };
    version = "3.1.1";
  };
  openssl = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1hj7wwp4r3jhvnyd8ik85wbs25cq1w61r28pv6ddyn5fd0lasdqh";
      type = "gem";
    };
    version = "4.0.2";
  };
  process-metrics = {
    dependencies = ["console" "json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "02ylwnpdfp0d95mmy6n6hch9lvbs35bvf0ksqs7rgi7sgmj04nky";
      type = "gem";
    };
    version = "0.15.0";
  };
  protocol-hpack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14ddqg5mcs9ysd1hdzkm5pwil0660vrxcxsn576s3387p0wa5v3g";
      type = "gem";
    };
    version = "1.5.1";
  };
  protocol-http = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k0r0ayp7vay880fmxy1j9zdqbp0qbyz0y6zyawrb54phm3lflxi";
      type = "gem";
    };
    version = "0.72.0";
  };
  protocol-http1 = {
    dependencies = ["protocol-http"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18qfic0k6w4bqw3n0w2hxprwi0562dns2ziydj4qm5182958fqwq";
      type = "gem";
    };
    version = "0.41.0";
  };
  protocol-http2 = {
    dependencies = ["protocol-hpack" "protocol-http"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06adk2f8rins5dgx1afsxqdv7nswbnyp2dqdqw2ps2vknmkyckiz";
      type = "gem";
    };
    version = "0.29.1";
  };
  protocol-rack = {
    dependencies = ["console" "io-stream" "protocol-http" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mq3ihw0afcrrjnadj6d4b9vxjvf8b8myd2ms4ymnmi03csc7vk3";
      type = "gem";
    };
    version = "0.23.0";
  };
  protocol-url = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08gvmgx5jqprix14ywznml39bkaxd3cvn3v1nfh5k8j2lxm9ysrz";
      type = "gem";
    };
    version = "0.19.0";
  };
  rack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dwgab330lsv4qppw3f52mc4ihr8lagxgll53mkmcdgr4hf3xqck";
      type = "gem";
    };
    version = "3.2.7";
  };
  rack-protection = {
    dependencies = ["base64" "logger" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1b4bamcbpk29i7jvly3i7ayfj69yc1g03gm4s7jgamccvx12hvng";
      type = "gem";
    };
    version = "4.2.1";
  };
  rack-session = {
    dependencies = ["base64" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s7zcxlmg88a6dam4aqbgk9xkpy6dkdfqmmcszkkliy3q3w38m2r";
      type = "gem";
    };
    version = "2.1.2";
  };
  ratalada = {
    dependencies = ["dry-configurable" "rack"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1i0vc0q2yah2lam9brbpiw3a9d9asgz594rf1bzbq2n6wssx3d7q";
      type = "gem";
    };
    version = "4.0.0";
  };
  ratalada-contrib = {
    dependencies = ["mustermann" "ratalada"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pgfri6li5ihqlp97w7gk9554x6ryh63sfv2nrkqcah565iqghba";
      type = "gem";
    };
    version = "4.0.0";
  };
  ratalada-sinatra = {
    dependencies = ["ratalada" "sinatra"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12s8zvd0kpfnib4xxy14jla9zm5hhwqgvviq9lb1j8kipy5r0mr8";
      type = "gem";
    };
    version = "4.0.0";
  };
  samovar = {
    dependencies = ["console"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15133m5jihv7pv00dcrg51yvrkw5qiw1dd0y6bq89046p0gc97wa";
      type = "gem";
    };
    version = "2.5.1";
  };
  sinatra = {
    dependencies = ["logger" "mustermann" "rack" "rack-protection" "rack-session" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "103h6wjpcqp3i034hi44za2v365yz7qk9s5df8lmasq43nqvkbmp";
      type = "gem";
    };
    version = "4.2.1";
  };
  string-format = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xlsg0m748bcb4vgvmjxlfsif6nnl8pz6ja52c91y1kb24a1r65w";
      type = "gem";
    };
    version = "0.2.0";
  };
  tilt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19d3k8ym9bj9j98zmc0pbjnwqdg4mqabnh8hm7lrdfhb5383amys";
      type = "gem";
    };
    version = "2.9.0";
  };
  zeitwerk = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1rcjpgyzmdxp8rdw466156fmr588k9q1wg8j42g0dkk7hid1519c";
      type = "gem";
    };
    version = "2.8.3";
  };
}
