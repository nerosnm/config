{
  chronic = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1hrdkn4g8x7dlzxwb1rfgr8kw3bp4ywg5l4y4i9c2g5cwv62yvvn";
      type = "gem";
    };
    version = "0.10.2";
  };
  deep_merge = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0fjn4civid68a3zxnbgyjj6krs3l30dy8b4djpg6fpzrsyix7kl3";
      type = "gem";
    };
    version = "1.2.2";
  };
  doing = {
    dependencies = ["chronic" "deep_merge" "gli" "haml" "safe_yaml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "05wpyb6wqn1zbs3x86pgwimv8hg4qyxwclpzh3d2li8w7yavd970";
      type = "gem";
    };
    version = "2.0.13";
  };
  gli = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0rv8dlq9nqpias29jh40qb6xzznlk6ra41nan6s5hy56402f0k29";
      type = "gem";
    };
    version = "2.21.0";
  };
  haml = {
    dependencies = ["temple" "tilt"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "1q0a9fvqh8kn6wm97fcks6qzbjd400bv8bx748w8v87m7p4klhac";
      type = "gem";
    };
    version = "5.0.4";
  };
  safe_yaml = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "0j7qv63p0vqcd838i2iy2f76c3dgwzkiz1d1xkg7n0pbnxj2vb56";
      type = "gem";
    };
    version = "1.0.5";
  };
  temple = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "060zzj7c2kicdfk6cpnn40n9yjnhfrr13d0rsbdhdij68chp2861";
      type = "gem";
    };
    version = "0.8.2";
  };
  tilt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["http://rubygems.org"];
      sha256 = "186nfbcsk0l4l86gvng1fw6jq6p6s7rc0caxr23b3pnbfb20y63v";
      type = "gem";
    };
    version = "2.0.11";
  };
}
