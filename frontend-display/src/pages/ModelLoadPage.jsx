import FormBackend from "../components/FormBackend";
import TopHeader from "../components/TopHeader";
import ForceLogin from "../components/ForceLogin";
import { useAuth0 } from "@auth0/auth0-react";

const ModelLoadPage = (data) => {
    const {isAuthenticated} = useAuth0();

    if(isAuthenticated == true){
    return (
        <div id="model-load">
            <h1>Load Model</h1>
            <FormBackend />
        </div>
    )
    }
    else{
        return(
        <>
        <ForceLogin/>
        </>
        )
    }
}

export default ModelLoadPage;