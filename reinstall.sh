#!/bin/bash

sudo gem uninstall muddyit_fu
gem build muddyit_fu.gemspec
sudo gem install -l muddyit_fu*.gem
