/**
 * Copyright (c) 2012, FinancialForce.com, inc
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, 
 *   are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, 
 *      this list of conditions and the following disclaimer.
 * - Redistributions in binary form must reproduce the above copyright notice, 
 *      this list of conditions and the following disclaimer in the documentation 
 *      and/or other materials provided with the distribution.
 * - Neither the name of the FinancialForce.com, inc nor the names of its contributors 
 *      may be used to endorse or promote products derived from this software without 
 *      specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND 
 *  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES 
 *  OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL 
 *  THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, 
 *  EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 *  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
 *  OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 *  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**/

public with sharing class ImportStaticResourceController
{
	public transient Blob Content {get; set;}
	public String UnzippedFile {get; set;}
	public MetadataService.AsyncResult AsyncResult {get; private set;}	
	private static String RESOURCE_NAME = 'upload'+UserInfo.getUserId();
	
	public PageReference upload() 
	{ 
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Uploading...'));

		// Metadata Service
		MetadataService.MetadataPort service = createService();
		
		// Map existing Static Resource files
    	List<MetadataService.ListMetadataQuery> queries = new List<MetadataService.ListMetadataQuery>();        
    	MetadataService.ListMetadataQuery queryStaticResource = new MetadataService.ListMetadataQuery();
    	queryStaticResource.type_x = 'StaticResource';
    	queries.add(queryStaticResource);     			
		MetadataService.FileProperties[] fileProperties = service.listMetadata(queries, 26);
		Map<String, MetadataService.FileProperties> mapFileProperties = new Map<String, MetadataService.FileProperties>(); 
		for(MetadataService.FileProperties fileProperty : fileProperties)
			mapFileProperties.put(fileProperty.fullName, fileProperty);
				
		// Uploads the file as a Static Resource
		MetadataService.StaticResource staticResource = new MetadataService.StaticResource();
		staticResource.fullName = RESOURCE_NAME;
		staticResource.contentType = 'application/zip';
		staticResource.cacheControl = 'private';
		staticResource.description = 'Temporary upload to unzip file for user ' + UserInfo.getName();
		staticResource.content = EncodingUtil.base64Encode(Content);
		if(mapFileProperties.containsKey(RESOURCE_NAME))
		{
			// Update existing Static Resource
			List<MetadataService.UpdateMetadata> updateMetadatas = new List<MetadataService.UpdateMetadata>();
			updateMetadatas.add(new MetadataService.UpdateMetadata());
			updateMetadatas[0].currentName = RESOURCE_NAME;
			updateMetadatas[0].metadata = staticResource;
 			AsyncResult = service.updateMetadata(updateMetadatas)[0];			
		}
		else
		{
			// Create new Static Resource
			AsyncResult = service.create(new List<MetadataService.Metadata> { staticResource })[0];
		} 		
 				
		return null;
	} 
	
	public PageReference checkAsyncRequest()
	{
		// Check the status of the create request
		MetadataService.MetadataPort service = createService();
		MetadataService.AsyncResult[] aysncResults = service.checkStatus(new String[] { AsyncResult.Id });
		if(aysncResults[0].done)
		{
			// Errors?
			if(aysncResults[0].state == 'Error')
			{
			 	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, aysncResults[0].message));
				AsyncResult = null;				
			}
			else
			{
				// Upload complete reset sync
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Info, 'Upload complete'));
				AsyncResult = null;
				
				// Unzip the /word/document.xml file
				PageReference contentTypes = new PageReference('/resource/' + RESOURCE_NAME + '/word/document.xml');
				UnzippedFile = contentTypes.getContent().toString();
			}
		}
		else
		{
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO,'Uploading...'));
		}	
		return null;		
	}
	
	public static MetadataService.MetadataPort createService()
	{ 
		MetadataService.MetadataPort service = new MetadataService.MetadataPort();
		service.SessionHeader = new MetadataService.SessionHeader_element();
		service.SessionHeader.sessionId = UserInfo.getSessionId();
		return service;		
	}	
}