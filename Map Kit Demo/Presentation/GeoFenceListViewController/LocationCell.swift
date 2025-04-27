//
//  LocationCell.swift
//  Map Kit Demo
//
//  Created by Abdullah-Shahid  on 28/04/2025.
//

import UIKit
import Anchorage

final class LocationCell: UITableViewCell {
    
    private let nameLabel = UILabel()
    private let longitudeLabel = UILabel()
    private let latitudeLabel = UILabel()
    private let radiusLabel = UILabel()
    private let noteLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        selectionStyle = .none
        
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.numberOfLines = 0
        longitudeLabel.font = UIFont.systemFont(ofSize: 14)
        latitudeLabel.font = UIFont.systemFont(ofSize: 14)
        radiusLabel.font = UIFont.systemFont(ofSize: 14)
        noteLabel.font = UIFont.italicSystemFont(ofSize: 14)
        noteLabel.numberOfLines = 0
        
        contentView.addSubview(nameLabel)
        contentView.addSubview(longitudeLabel)
        contentView.addSubview(latitudeLabel)
        contentView.addSubview(radiusLabel)
        contentView.addSubview(noteLabel)
    }
    
    private func setupConstraints() {
        nameLabel.topAnchor == contentView.topAnchor + 8
        nameLabel.horizontalAnchors == contentView.horizontalAnchors + 16
        
        longitudeLabel.topAnchor == nameLabel.bottomAnchor + 4
        longitudeLabel.horizontalAnchors == nameLabel.horizontalAnchors
        
        latitudeLabel.topAnchor == longitudeLabel.bottomAnchor + 4
        latitudeLabel.horizontalAnchors == nameLabel.horizontalAnchors
        
        radiusLabel.topAnchor == latitudeLabel.bottomAnchor + 4
        radiusLabel.horizontalAnchors == nameLabel.horizontalAnchors
        
        noteLabel.topAnchor == radiusLabel.bottomAnchor + 8
        noteLabel.horizontalAnchors == nameLabel.horizontalAnchors
        noteLabel.bottomAnchor == contentView.bottomAnchor - 8
    }
    
    func configure(with location: GeoFence) {
        nameLabel.text = "Name: \(location.name ?? "")"
        longitudeLabel.text = String(format: "Longitude: %.4f", location.centerLongitude)
        latitudeLabel.text = String(format: "Latitude: %.4f", location.centerLatitude)
        radiusLabel.text = "Radius: \(location.radius) meters"
        noteLabel.text = "Note: \(location.userNote ?? "")"
    }
}
