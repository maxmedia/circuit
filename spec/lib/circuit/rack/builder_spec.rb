require 'spec_helper'

describe Circuit::Rack::Builder do
  context "without an app" do
    subject { Circuit::Rack::Builder.new }
    it { should respond_to(:app?) }
    it { subject.app?.should be_false }
  end

  context "with an app" do
    subject { Circuit::Rack::Builder.new(lambda { |env| [200, {}, %w[OK]]}) }
    it { should respond_to(:app?) }
    it { subject.app?.should be_true }
  end

  context "defers to ::Rack::Builder for .ru files" do
    subject { Circuit::Rack::Builder.parse_file(Circuit.cru_path.join("render_not_found.ru")).first }
    it { should be_instance_of(Circuit::Rack::Builder) }
    it do
      ::Rack::Builder.expects(:parse_file).once
      subject
    end
    after { ::Rack::Builder.unstub(:parse_file) }
  end

  context "parses .cru files" do
    subject { Circuit::Rack::Builder.parse_file(Circuit.cru_path.join("render_ok.cru")).first }
    it { should be_instance_of(Circuit::Rack::Builder) }
    it do
      ::Rack::Builder.expects(:parse_file).never
      subject
    end
    after { ::Rack::Builder.unstub(:parse_file) }
  end

  context "dup without map" do
    let(:use) { [mock()] }
    let(:run) { mock() }

    subject do
      ::Rack::Builder.new.tap do |b|
        b.instance_variable_set(:@use, use)
        b.instance_variable_set(:@run, run)
      end.dup
    end

    it { subject.instance_variable_get(:@run).should equal(run) }
    it { subject.instance_variable_get(:@use).should eql(use) }
    it { subject.instance_variable_get(:@use).should_not equal(use) }
    it { subject.instance_variable_get(:@map).should be_nil }
    it { subject.dup.instance_variable_get(:@map).should be_nil }
  end

  context "dup with map" do
    let(:use) { [mock()] }
    let(:map) { {"/" => mock()} }
    let(:run) { mock() }

    subject do
      ::Rack::Builder.new.tap do |b|
        b.instance_variable_set(:@use, use)
        b.instance_variable_set(:@map, map)
        b.instance_variable_set(:@run, run)
      end.dup
    end

    it { subject.instance_variable_get(:@run).should equal(run) }
    it { subject.instance_variable_get(:@use).should eql(use) }
    it { subject.instance_variable_get(:@use).should_not equal(use) }
    it { subject.instance_variable_get(:@map).should eql(map) }
    it { subject.instance_variable_get(:@map).should_not equal(map) }
  end
end

describe ::Rack::Builder do
  context "without an app" do
    subject { ::Rack::Builder.new }
    it { should respond_to(:app?) }
    it { subject.app?.should be_false }
  end

  context "with an app" do
    subject { ::Rack::Builder.new(lambda { |env| [200, {}, %w[OK]]}) }
    it { should respond_to(:app?) }
    it { subject.app?.should be_true }
  end

  context "dup without map" do
    let(:use) { [mock()] }
    let(:run) { mock() }

    subject do
      ::Rack::Builder.new.tap do |b|
        b.instance_variable_set(:@use, use)
        b.instance_variable_set(:@run, run)
      end.dup
    end

    it { subject.instance_variable_get(:@run).should equal(run) }
    it { subject.instance_variable_get(:@use).should eql(use) }
    it { subject.instance_variable_get(:@use).should_not equal(use) }
    it { subject.instance_variable_get(:@map).should be_nil }
    it { subject.dup.instance_variable_get(:@map).should be_nil }
  end

  context "dup with map" do
    let(:use) { [mock()] }
    let(:map) { {"/" => mock()} }
    let(:run) { mock() }

    subject do
      ::Rack::Builder.new.tap do |b|
        b.instance_variable_set(:@use, use)
        b.instance_variable_set(:@map, map)
        b.instance_variable_set(:@run, run)
      end.dup
    end

    it { subject.instance_variable_get(:@run).should equal(run) }
    it { subject.instance_variable_get(:@use).should eql(use) }
    it { subject.instance_variable_get(:@use).should_not equal(use) }
    it { subject.instance_variable_get(:@map).should eql(map) }
    it { subject.instance_variable_get(:@map).should_not equal(map) }
  end
end