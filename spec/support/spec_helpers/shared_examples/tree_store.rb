require "active_support/core_ext/string/inflections"

shared_examples "tree store" do
  subject { Circuit.tree_store }
  it { should be_instance_of(Circuit::Storage::Trees.const_get(store.to_s.classify)) }

  context "get root" do
    before { root }
    it { subject.get(site, "/").should == [root] }
  end

  context "get nodes" do
    # before { great_grandchild }
    it do
      subject.get(site, great_grandchild.path).
        should == [root, child, grandchild, great_grandchild]
    end
  end

  context "get missing route" do
    before { child }
    it { subject.get(site, child.path+"/foobar").should be_nil }
    it do
      expect { subject.get!(site, child.path+"/foobar") }.
        to raise_error(Circuit::Storage::Trees::NotFoundError, "Path not found")
    end
  end

  describe Circuit::Tree do
    subject { child }

    context "has slug" do
      it { should respond_to(:slug) }
      it { subject.slug.should_not be_blank}
    end

    context "requires slug" do
      before { subject.slug = nil }
      it { subject.save.should be_false }
    end

    context "has behavior_klass" do
      it { should respond_to(:behavior_klass) }
      it { subject.behavior_klass.should_not be_blank}
    end

    context "requires behavior_klass" do
      before { subject.behavior_klass = nil }
      it { subject.save.should be_false }
    end

    context "behavior is constantized behavior_klass" do
      it { subject.behavior.should == subject.behavior_klass.constantize }
    end

    context "behavior_klass is settable by behavior=" do
      before { subject.behavior = Behaviors::Forward }
      it { subject.behavior_klass.should == "Behaviors::Forward" }
    end

    context "root has a site, slug is nil" do
      it { root.site.should == site }
      it { root.root?.should be_true}
      it { root.slug.should be_nil }
    end

    context "child does not have a site" do
      it { subject.site.should be_nil }
      it { subject.root?.should be_false }
    end

    context "child should build path" do
      it { subject.path.should == "/#{subject.slug}" }
    end
  end
end
