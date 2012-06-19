require 'spec_helper'
require 'circuit/validators'

describe Circuit::Validators do
  describe Circuit::Validators::DomainValidator do
    subject { DomainValidator.new(:attributes => :domain) }
    let(:record) { stub(:errors => ActiveModel::Errors.new(nil)) }

    context "with a top level domain" do
      before { subject.validate_each(record, :domain, "localhost") }
      it { record.errors.should be_empty }
    end

    context "with a real domain name" do
      before { subject.validate_each(record, :domain, "google.com") }
      it { record.errors.should be_empty }
    end

    context "with a subdomain" do
      before { subject.validate_each(record, :domain, "plus.google.com") }
      it { record.errors.should be_empty }
    end

    context "with a invalid characters" do
      before { subject.validate_each(record, :domain, "bad%domain.com") }
      it { record.errors.to_hash.should == {:domain => ["is not a valid domain."]} }
    end
  end

  describe Circuit::Validators::DomainArrayValidator do
    subject { DomainArrayValidator.new(:attributes => :aliases) }
    let(:record) { stub(:errors => ActiveModel::Errors.new(nil)) }

    context "with a String" do
      before { subject.validate_each(record, :domain, "localhost") }
      it { record.errors.should be_empty }
    end

    context "with an empty array" do
      before { subject.validate_each(record, :domain, []) }
      it { record.errors.should be_empty }
    end

    context "with multiple bad domains" do
      before { subject.validate_each(record, :domain, %w[bad%domain1.com bad%domain2.com]) }
      it { record.errors.to_hash.should == {:domain => ["has an invalid domain."]} }
    end

    context "with all good domains" do
      before { subject.validate_each(record, :domain, %w[google.com plus.google.com www.google.com]) }
      it { record.errors.should be_empty }
    end
  end

  describe Circuit::Validators::SlugValidator do
    subject { SlugValidator.new(:attributes => :slug) }
    let(:record) { stub(:errors => ActiveModel::Errors.new(nil)) }

    context "with a valid slug" do
      before { subject.validate_each(record, :slug, "a-path-segment") }
      it { record.errors.should be_empty }
    end

    context "with an invalid slug" do
      before { subject.validate_each(record, :slug, "%") }
      it { record.errors.to_hash.should == {:slug => ["is not a valid path segment."]} }
    end
  end
end
