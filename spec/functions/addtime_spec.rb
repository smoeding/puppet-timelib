require 'spec_helper'

describe 'addtime' do
  EINVAL = /wrong number of arguments/i
  EINFMT = /Wrong format/i
  ERANGE = /argument out of range/i

  it { is_expected.not_to eq(nil) }

  it 'should exist' do
    expect(Puppet::Parser::Functions.function("addtime")) \
      .to eq("function_addtime")
  end

  describe 'signature validation' do
    it 'with no arguments' do
      is_expected.to run.with_params() \
                      .and_raise_error(Puppet::ParseError, EINVAL)
    end

    it 'with one argument' do
      is_expected.to run.with_params('0') \
                      .and_raise_error(Puppet::ParseError, EINVAL)
    end

    it 'with four arguments' do
      is_expected.to run.with_params('0', '0', '0', '0') \
                      .and_raise_error(Puppet::ParseError, EINVAL)
    end
  end

  describe 'first argument format' do
    it 'with time => foo' do
      is_expected.to run.with_params('foo', 'PT1H') \
                      .and_raise_error(Puppet::ParseError, EINFMT)
    end

    it 'with time => 0:' do
      is_expected.to run.with_params('0:', 'PT1H') \
                      .and_raise_error(Puppet::ParseError, EINFMT)
    end

    it 'with time => :0' do
      is_expected.to run.with_params(':0', 'PT1H') \
                      .and_raise_error(Puppet::ParseError, EINFMT)
    end

    it 'with time => 0:0:0:0' do
      is_expected.to run.with_params('0:0:0:0', 'PT1H') \
                      .and_raise_error(Puppet::ParseError, EINFMT)
    end

    it 'with time => 0:60:0' do
      is_expected.to run.with_params('0:60:0', 'PT1H') \
                      .and_raise_error(Puppet::ParseError, ERANGE)
    end

    it 'with time => 0:0:60' do
      is_expected.to run.with_params('0:0:60', 'PT1H') \
                      .and_raise_error(Puppet::ParseError, ERANGE)
    end
  end

  describe 'second argument format' do
    it 'with interval => foo' do
      is_expected.to run.with_params('00:00:00', 'foo') \
                      .and_raise_error(Puppet::ParseError, EINFMT)
    end

    it 'with interval => PT' do
      is_expected.to run.with_params('00:00:00', 'PT') \
                      .and_raise_error(Puppet::ParseError, EINFMT)
    end

    it 'with interval => PT1' do
      is_expected.to run.with_params('00:00:00', 'PT1') \
                      .and_raise_error(Puppet::ParseError, EINFMT)
    end
  end

  it { is_expected.to run.with_params('00:00:00', 'PT1S').and_return('00:00:01') }
  it { is_expected.to run.with_params('00:00:00', 'PT1M').and_return('00:01:00') }
  it { is_expected.to run.with_params('00:00:00', 'PT1H').and_return('01:00:00') }

  it { is_expected.to run.with_params('23:59:59', 'PT1S').and_return('00:00:00') }
  it { is_expected.to run.with_params('23:59:00', 'PT1M').and_return('00:00:00') }
  it { is_expected.to run.with_params('23:00:00', 'PT1H').and_return('00:00:00') }

  it { is_expected.to run.with_params('00:00:00', 'PT1H1S').and_return('01:00:01') }
  it { is_expected.to run.with_params('00:00:00', 'PT1M1S').and_return('00:01:01') }
  it { is_expected.to run.with_params('00:00:00', 'PT1H1M').and_return('01:01:00') }
  it { is_expected.to run.with_params('00:00:00', 'PT1H1M1S').and_return('01:01:01') }

  it { is_expected.to run.with_params('00:00:00', 'PT24H').and_return('00:00:00') }
  it { is_expected.to run.with_params('11:03:17', 'PT56M43S').and_return('12:00:00') }
  it { is_expected.to run.with_params('00:00', 'PT6H', true).and_return([ 6, 0, 0 ]) }
end
