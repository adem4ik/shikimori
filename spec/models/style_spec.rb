describe Style do
  describe 'relations' do
    it { is_expected.to belong_to :owner }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :owner }
  end

  describe 'instance methods' do
    describe '#compiled_css' do
      let(:style) { build :style, css: css }

      context '#strip_comments' do
        let(:css) { '/* test */ test' }
        it { expect(style.compiled_css).to eq 'test' }
      end

      context '#camo_images' do
        let(:image_url) { 'http://s8.hostingkartinok.com/uploads/images/2016/02/87303db8016e56e8a9eeea92f81f5760.jpg' }
        let(:css) { "body { background: url(#{image_url}); };" }
        it do
          expect(style.compiled_css).to eq(
            "body { background: url(#{UrlGenerator.instance.camo_url image_url}); };"
          )
        end
      end

      context '#sanitize' do
        let(:css) { 'body { color: red; }; javascript:blablalba;;' }
        it { expect(style.compiled_css).to eq 'body { color: red; }; :blablalba;' }
      end
    end
  end

  describe 'permissions' do
    let(:user) { build_stubbed :user, :user }
    subject { Ability.new user }

    context 'owner' do
      let(:style) { build_stubbed :style, owner: user }

      context 'not style of owner' do
        it { is_expected.to be_able_to :show, style }
        it { is_expected.to be_able_to :preview, style }
        it { is_expected.to be_able_to :create, style }
        it { is_expected.to be_able_to :update, style }
        it { is_expected.to be_able_to :destroy, style }
      end

      context 'style of owner' do
        before { user.style = style }

        it { is_expected.to be_able_to :show, style }
        it { is_expected.to be_able_to :preview, style }
        it { is_expected.to be_able_to :create, style }
        it { is_expected.to be_able_to :update, style }
        it { is_expected.to_not be_able_to :destroy, style }
      end
    end

    context 'guest' do
      let(:style) { build_stubbed :style }
      let(:user) { nil }

      it { is_expected.to be_able_to :show, style }
      it { is_expected.to be_able_to :preview, style }
      it { is_expected.to_not be_able_to :create, style }
      it { is_expected.to_not be_able_to :update, style }
      it { is_expected.to_not be_able_to :destroy, style }
    end

    context 'user' do
      let(:style) { build_stubbed :style }
      let(:user) { nil }

      it { is_expected.to be_able_to :show, style }
      it { is_expected.to be_able_to :preview, style }
      it { is_expected.to_not be_able_to :create, style }
      it { is_expected.to_not be_able_to :update, style }
      it { is_expected.to_not be_able_to :destroy, style }
    end
  end
end
