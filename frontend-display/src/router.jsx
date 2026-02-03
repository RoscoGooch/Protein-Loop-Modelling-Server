import { createBrowserRouter } from 'react-router-dom';
import { HomeLayoutPage, ErrorPage, IndexPage, ModelLoadPage, ModelDisplayPage} from './pages/index';


export const router = createBrowserRouter([
    {
        path: "/",
        element: <HomeLayoutPage />,
        errorElement: <ErrorPage />,
        children: [
            {
                index: true,
                element: <IndexPage />
            },
            {
                path: "/loadmodel",
                element: <ModelLoadPage />
            },
            {
                path: "/displaymodel",
                element: <ModelDisplayPage />
            }
        ]    
    },
]);    