import React from "react";
import UserContainer from "./UserContainer";
import { useDispatch } from "react-redux";
import { useNavigate } from "react-router-dom";
import { useAuth0, User } from "@auth0/auth0-react";
import MenuTitle from "./MenuTitle";

const TopHeader = () => {
    const dispatch = useDispatch();
    const navigate = useNavigate();

    const {isAuthenticated, loginWithRedirect, logout, user, isLoading} = useAuth0();

    console.log({
    isAuthenticated,
    user,
    isLoading
    })

    return (
    <div className="top-banner">
      <MenuTitle title="Protein Loop Modelling Server"/>
      <UserContainer user={user} login={loginWithRedirect} logout={logout}/>
    </div>    
    )
};

export default TopHeader;