import React, { Component } from 'react';
import { BrowserRouter as Router, Route, Link } from 'react-router-dom';
import './resources/styles.css';
import "slick-carousel/slick/slick.css";
import "slick-carousel/slick/slick-theme.css";

import Header from './components/header_footer/Header';
import Featured from './components/featured';

class App extends Component {
  render() {
    return (
      <Router>
        <div className="App" style={{ height: "1500px", background: "cornflowerblue" }}>
          <Header />
          <Featured />
        </div>
      </Router>
    );
  }
}

export default App;
