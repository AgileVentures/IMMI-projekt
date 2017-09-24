module PickRandomHelpers



  # return a random new membership application
  def random_member_app(application_state = :new)

    app_ids = MembershipApplication.where(state: application_state).pluck(:id)

    rand_id_index = Random.rand(app_ids.count)

    MembershipApplication.find( app_ids[rand_id_index])

  end


  def random_user
    user_ids = User.pluck(:id)

    rand_id_index = Random.rand(user_ids.count)
    User.find( user_ids[rand_id_index] )

  end

end


