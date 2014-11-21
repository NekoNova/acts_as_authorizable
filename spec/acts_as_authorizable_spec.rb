require 'spec_helper'

describe 'acts_as_authorizable' do
  # Generate the required information in the memory database, so we have information
  # to work with during the tests.
  before(:all) do
    # Generate the Users
    m = create(:user, name: 'Matt')
    d = create(:user, name: 'Dave')
    create(:user, name: 'Charles')
    create(:user, name: 'Joe')
    create(:user, name: 'Tom')

    # Generate the Forum
    forum = create(:forum, name: 'Support')

    # Generate the Roles
    mod = create(:role, name: 'Forum Moderator', permissions: 'moderate, view')
    v = create(:role, name: 'Forum Viewer', permissions: 'view')
    create(:role, name: 'Thread Moderator', permissions: 'moderate')
    create(:role, name: 'Post Owner', permissions: 'owns')

    # Generate the Thread
    t = create(:forum_thread, name: 'Thread A', forum: forum, moderator: m)

    # Generate the Post
    create(:post, name: 'My First Post', forum_thread: t, owner: m)

    # Generate the memberships
    create(:forum_membership, user: m, forum: forum, role: mod)
    create(:forum_membership, user: d, forum: forum, role: v)
  end

  it 'sets the options correctly' do
    expect(Forum.acts_as_authorizable_options[:role_class_name]).to eq('Role')
    expect(Forum.acts_as_authorizable_options[:role_locate_method]).to eq('find_by_name')
  end

  it 'sets the size of the sources correctly' do
    expect(Post.acts_as_authorizable_sources.size).to eq(2)
    expect(ForumMembership.acts_as_authorizable_sources.size).to eq(1)
  end

  it 'respects the lexical order' do
    expect(Post.acts_as_authorizable_sources.first[:type]).to eq(:belongs_to_user)
    expect(Post.acts_as_authorizable_sources.last[:type]).to eq(:belongs_to_parent)
  end

  it 'functions properly in a belongs_to relation' do
    expect(ForumMembership.acts_as_authorizable_sources.first[:type]).to eq(:belongs_to_user)
    expect(ForumMembership.acts_as_authorizable_sources.first[:association]).to eq(:user)
    expect(ForumMembership.acts_as_authorizable_sources.first[:role_association]).to eq(:role)
    expect(ForumMembership.acts_as_authorizable_sources.first[:role]).to be_nil
  end

  it 'functions properly in a hardcoded relation' do
    expect(Post.acts_as_authorizable_sources.first[:role]).to eq('Post Owner')
  end

  it 'functions properly in a parent-child relation' do
    expect(Post.acts_as_authorizable_sources.last[:association]).to eq(:forum_thread)
  end

  it 'checks if the sources are getting the has_many parent properly' do
    expect(Forum.acts_as_authorizable_sources.first[:association]).to eq(:forum_memberships)
  end

  it 'Tests that sources is getting has_many parents properly with scope' do
    expect(Forum.acts_as_authorizable_sources.first[:user_scope]).to eq(:with_user)
  end

  it 'Tests that auth_user_association_matches? works' do
    u = User.find_by_name('Dave')
    u2 = User.find_by_name('Matt')
    f = u.forum_memberships.first
    expect(f.send('auth_user_association_matches?',:user,u)).to be_truthy
    expect(f.send('auth_user_association_matches?',:user,u2)).to be_falsey
  end

  it 'Tests that auth_locate_role_object works' do
    r = Role.find_by_name('Post Owner')
    p = Post.first
    expect(p.send('auth_locate_role_object','Post Owner')).to eq(r)
  end

  it 'Tests that auth_assoc_using_has_many_parents works with scope' do
    f = Forum.find_by_name('Support')
    u = User.find_by_name('Matt')
    assoc = f.send('auth_assoc_using_has_many_parents',f.acts_as_authorizable_sources.first, u)
    expect(assoc.size).to eq(1)
    expect(assoc.first.role.name).to eq('Forum Moderator')
  end

  it 'Tests that auth_using_belongs_to_user fetches the correct role object' do
    p = Post.first
    u = User.find_by_name('Matt')
    u2 = User.find_by_name('Dave')
    expect(p.send('auth_using_belongs_to_user',Post.acts_as_authorizable_sources.first,u,'owns').name).to eq('Post Owner')
    expect(p.send('auth_using_belongs_to_user',Post.acts_as_authorizable_sources.first,u2,'owns')).to be_nil
    expect(p.send('auth_using_belongs_to_user',Post.acts_as_authorizable_sources.first,u,'ow2ns')).to be_nil
  end

  it 'Tests a direct authorization using a belongs_to_user' do
    u = User.find_by_name('Matt')
    m = u.forum_memberships.first
    expect(m.authorized?(u,'moderate')).to be_truthy
  end

  it 'Tests a indirect authorization using a belongs_to_parent scoped' do
    u = User.find_by_name('Matt')
    f = u.forum_memberships.first.forum
    expect(f.authorized?(u,'moderate')).to be_truthy
  end

  it 'Tests a long authorization using two hops with other branches' do
    u = User.find_by_name('Matt')
    t = u.forum_memberships.first.forum.forum_threads.first
    expect(t.authorized?(u,'moderate')).to be_truthy
  end
end