require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login to layout links" do
    log_in_as(@user)
    get root_path
    # ブラウザに渡すhtmlの場所が正しいか
    assert_template 'static_pages/home'
    # リンクが合っているか
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", user_path(@user)
    assert_select "a[href=?]", edit_user_path(@user)
    assert_select "a[href=?]", logout_path
  end
  test "layout links" do
    # ============================================================
    #  ホーム画面のテスト
    # ============================================================
    get root_path
    # ブラウザに渡すhtmlの場所が正しいか
    assert_template 'static_pages/home'
    # リンクが合っているか
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", signup_path
    assert_select "a[href=?]", login_path
    

    # ============================================================
    #  問い合わせ画面のテスト
    # ============================================================
    get contact_path
    assert_select "title", full_title("Contact")
  end
end
