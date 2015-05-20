require boxen::environment
require homebrew
require gcc

Exec {
  group       => 'staff',
  logoutput   => on_failure,
  user        => $boxen_user,

  path => [
    "${boxen::config::home}/rbenv/shims",
    "${boxen::config::home}/rbenv/bin",
    "${boxen::config::home}/rbenv/plugins/ruby-build/bin",
    "${boxen::config::homebrewdir}/bin",
    '/usr/bin',
    '/bin',
    '/usr/sbin',
    '/sbin'
  ],

  environment => [
    "HOMEBREW_CACHE=${homebrew::config::cachedir}",
    "HOME=/Users/${::boxen_user}"
  ]
}

File {
  group => 'staff',
  owner => $boxen_user
}

Package {
  provider => homebrew,
  require  => Class['homebrew']
}

Repository {
  provider => git,
  extra    => [
    '--recurse-submodules'
  ],
  require  => File["${boxen::config::bindir}/boxen-git-credential"],
  config   => {
    'credential.helper' => "${boxen::config::bindir}/boxen-git-credential"
  }
}

Service {
  provider => ghlaunchd
}

Homebrew::Formula <| |> -> Package <| |>

node default {
  # core modules, needed for most things
  include dnsmasq
  include git
  include hub
  include nginx
  include java
  include virtualbox
  include osxfuse
  include ntfs_3g
  include nvm

  # OS X Settings
  include osx::dock::autohide
  include osx::dock::disable
  include osx::dock::disable_dashboard
  include osx::finder::unhide_library
  include osx::finder::show_hidden_files
  include osx::finder::enable_quicklook_text_selection
  include osx::finder::show_all_filename_extensions
  include osx::safari::enable_developer_mode

  # Android
  include android::sdk
  include android::tools
  include android::platform_tools
  include android::doc
  android::build_tools { '22.0.1': }
  include sublime_text
  sublime_text::package { 'Emmet':
    source => 'sergeche/emmet-sublime'
  }
  sublime_text::package { 'Package Control':
    source => 'wbond/sublime_package_control'
  }
  sublime_text::package { 'Bracket Highlighter':
    source => 'facelessuser/BracketHighlighter'
  }
  sublime_text::package { 'Sidebar Enhancements':
    source => 'titoBouzout/SideBarEnhancements'
  }
  sublime_text::package { 'Alignment':
    source => 'wbond/sublime_alignment'
  }
  sublime_text::package { 'Color Picker':
    source => 'jnordberg/sublime-colorpick'
  }
  sublime_text::package { 'Markdown Editing':
    source => 'SublimeText-Markdown/MarkdownEditing'
  }
  sublime_text::package { 'Solarized Theme':
    source => 'electricgraffitti/soda-solarized-dark-theme'
  }

  # fail if FDE is not enabled
  if $::root_encrypted == 'no' {
    fail('Please enable full disk encryption and try again')
  }

  # # node versions
  # nodejs::version { 'v0.6': }
  # nodejs::version { 'v0.8': }
  # nodejs::version { 'v0.10': }
  # nodejs::version { 'v0.12.3': }

  # default ruby versions
  ruby::version { '1.9.3': }
  ruby::version { '2.0.0': }
  ruby::version { '2.1.0': }
  ruby::version { '2.1.1': }
  ruby::version { '2.1.2': }

  # common, useful packages
  package {
    [
      'ack',
      'findutils',
      'gnu-tar'
    ]:
  }

  file { "${boxen::config::srcdir}/our-boxen":
    ensure => link,
    target => $boxen::config::repodir
  }
}
