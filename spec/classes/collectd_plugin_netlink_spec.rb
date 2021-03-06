require 'spec_helper'

describe 'collectd::plugin::netlink', type: :class do
  let :facts do
    {
      osfamily: 'RedHat',
      collectd_version: '4.8.0',
      operatingsystemmajrelease: '7'
    }
  end

  context ':ensure => present, specific params' do
    let :params do
      {
        interfaces: %w(eth0 eth1),
        verboseinterfaces: ['ppp0'],
        qdiscs: ['"eth0" "pfifo_fast-1:0"', '"ppp0"'],
        classes: ['"ppp0" "htb-1:10"'],
        filters: ['"ppp0" "u32-1:0"'],
        ignoreselected: false

      }
    end
    it 'Will create /etc/collectd.d/10-netlink.conf' do
      should contain_file('netlink.load').with(ensure: 'present',
                                               path: '/etc/collectd.d/10-netlink.conf')
    end
    it { should contain_file('netlink.load').with_content(%r{^<Plugin netlink>$}) }
    it { should contain_file('netlink.load').with_content(%r{^  Interface "eth0"$}) }
    it { should contain_file('netlink.load').with_content(%r{^  Interface "eth1"$}) }
    it { should contain_file('netlink.load').with_content(%r{^  VerboseInterface "ppp0"$}) }
    it { should contain_file('netlink.load').with_content(%r{^  QDisc "eth0" "pfifo_fast-1:0"$}) }
    it { should contain_file('netlink.load').with_content(%r{^  QDisc "ppp0"$}) }
    it { should contain_file('netlink.load').with_content(%r{^  Class "ppp0" "htb-1:10"$}) }
    it { should contain_file('netlink.load').with_content(%r{^  Filter "ppp0" "u32-1:0"$}) }
    it { should contain_file('netlink.load').with_content(%r{^  IgnoreSelected false$}) }
    it do
      should contain_package('collectd-netlink').with(
        ensure: 'present'
      )
    end
  end

  context ':ensure => absent' do
    let :params do
      { interfaces: ['eth0'], ensure: 'absent' }
    end
    it 'Will not create /etc/collectd.d/10-netlink.conf' do
      should contain_file('netlink.load').with(ensure: 'absent',
                                               path: '/etc/collectd.d/10-netlink.conf')
    end
    it do
      should contain_package('collectd-netlink').with(
        ensure: 'absent'
      )
    end
  end

  context ':interfaces is not an array' do
    let :params do
      { interfaces: 'eth0' }
    end
    it 'Will raise an error about :interfaces being a String' do
      should compile.and_raise_error(%r{String})
    end
  end
end
