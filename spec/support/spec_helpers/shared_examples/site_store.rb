require "active_support/inflector"

shared_examples "site store" do
  subject { Circuit.site_store }
  it { should be_instance_of(Circuit::Storage::Sites.const_get(store.to_s.classify)) }

  context "get host" do
    before { root }
    it { subject.get(site.host).should eql(site) }
  end

  context "get alias" do
    it { subject.get(site.aliases.first).should == site }
  end

  context "get missing host" do
    it { subject.get("www.missinghost.com").should be_nil }
    it do
      expect { subject.get!("www.missinghost.com") }.
        to raise_error(Circuit::Storage::Sites::NotFoundError, "Host not found")
    end
  end

  context "get duplicated host" do
    it do
      expect { dup_site_1_dup; subject.get(dup_site_1.host) }.
        to raise_error(Circuit::Storage::Sites::MultipleFoundError, "Multiple sites found")
    end
  end

  context "get duplicated host by alias" do
    it do
      expect { dup_site_2_dup; subject.get(dup_site_2.host) }.
        to raise_error(Circuit::Storage::Sites::MultipleFoundError, "Multiple sites found")
    end
  end

  context "get duplicated alias" do
    it do
      expect { dup_site_3_dup; subject.get(dup_site_3.aliases.first) }.
        to raise_error(Circuit::Storage::Sites::MultipleFoundError, "Multiple sites found")
    end
  end

  describe Circuit::Site do
    subject { site }

    context "has aliases" do
      it { should respond_to(:aliases) }
      it { subject.aliases.should_not be_blank }
      it { subject.aliases.should be_a(Array) }
      it { subject.aliases.length.should == 1 }
    end

    context "allows blank aliases" do
      before { subject.aliases = [] }
      it { subject.aliases.should be_empty }
      it { subject.save.should be_true }
    end

    context "has host" do
      it { should respond_to(:host) }
      it { subject.host.should_not be_blank}
    end

    context "requires hosts" do
      before { subject.host = nil }
      it { subject.save.should be_false }
    end

    context "has route" do
      before { root }
      it { subject.route.should == root }
    end
  end
end
